{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MultipartFormDataParserImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    ListIntf,
    DependencyContainerIntf,
    MultipartFormDataParserIntf,
    EnvironmentIntf,
    UploadedFileCollectionWriterIntf,
    UploadedFileCollectionWriterFactoryIntf;

type

    (*!----------------------------------------------
     * basic implementation having capability as
     * parse multipart/form-data request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMultipartFormDataParser = class(TInterfacedObject, IMultipartFormDataParser)
    private
        uploadedFilesFactory : IUploadedFileCollectionWriterFactory;

        (*!----------------------------------------------
         * extract boundary from multipart/form-data content type
         * header
         *-------- --------------------------------------
         * @param contentType content type header
         * @return boundary of multipart/form-data
         *------------------------------------------------
         * For example if we have header as follows:         *
         * Content-Type: multipart/form-data; boundary=xxx12345678
         *
         * contentType parameter will contain string
         * 'multipart/form-data; boundary=xxx12345678'
         *
         * this method will return string 'xxx12345678'
         *-----------------------------------------------*)
        function getBoundary(const contentType : string) : string;

        (*!----------------------------------------
         * parse data in string store parsed data in body request parameter
         * and uploaded files (if any).
         *------------------------------------------
         * @param actualData actual data to parse
         * @param body instance of IList that will store
         *             parsed body parameter
         * @param uploadedFiles instance of uploaded file collection
         *-------------------------------------------
         * Example of actualData
         *
         * Content-Disposition: form-data; name="text"
         * \r\n
         * text default
         *------------------------------------------*)
        procedure parseData(
            const actualData : string;
            const body : IList;
            const uploadedFiles : IUploadedFileCollectionWriter
        );

        (*!----------------------------------------
         * Read POST data in standard input and parse
         * it and store parsed data in body request parameter
         * and uploaded files (if any).
         *------------------------------------------
         * @param env CGI environment variable
         * @param body instance of IList that will store
         *             parsed body parameter
         * @param uploadedFiles instance of uploaded file collection
         * @return current instance
         *-------------------------------------------
         * Example of POST data with boundary of 'xxx12345678' s
         *
         * --xxx12345678
         * Content-Disposition: form-data; name="text"
         * \r\n
         * text default
         * --xxx12345678
         * Content-Disposition: form-data; name="file1"; filename="a.txt"
         * Content-Type: text/plain
         * \r\n
         * Content of a.txt.
         *
         * --xxx12345678
         * Content-Disposition: form-data; name="file2"; filename="a.html"
         * Content-Type: text/html
         * \r\n
         * <!DOCTYPE html><title>Content of a.html.</title>
         *
         * --xxx12345678--
         * @link : https://stackoverflow.com/questions/4238809/example-of-multipart-form-data
         *------------------------------------------
         * Instead of read all standard input and collecting
         * them as one big string and then parse them,
         * we will read std input and parse data as soon as we
         * found matching boundary
         *------------------------------------------*)
        procedure readAndParseInputStream(
           const inputStream : TStream;
           const body : IList;
           const uploadedFiles : IUploadedFileCollectionWriter;
           const contentLength : integer;
           const boundary : string
        );

        (*!-------------------------------------------------------------
         * extract name from Content-Disposition
         *--------------------------------------------------------------
         * @param start starting index for extracting name
         * @param header header part
         * @return name
         *--------------------------------------------------------------
         * If we have header contains following line
         *
         * Content-Disposition: form-data; name="file2"; filename="a.html"
         * Content-Type: text/html
         *
         * start will contains value 32, start index of 'name="' substring
         * from pos() function
         * then this method will return string file2
         *--------------------------------------------------------------*)
        function extractName(const start: integer; const header : string) : string;

        (*!-------------------------------------------------------------
         * extract variable name from Content-Disposition
         *--------------------------------------------------------------
         * @param header header part
         * @return name
         * @throws EInvalidRequest if name is not found
         *--------------------------------------------------------------
         * If we have header contains following line
         *
         * Content-Disposition: form-data; name="file2"; filename="a.html"
         * Content-Type: text/html
         *
         * then this method will return string file2 or raise exception
         * if name is not found
         *--------------------------------------------------------------*)
        function extractVariableName(const headerPart : string) : string;
    public

        (*!----------------------------------------
         * constructor
         *------------------------------------------
         * @param factory factory instance to build uploaded file
         *        collection instance
         *------------------------------------------*)
        constructor create(const factory : IUploadedFileCollectionWriterFactory);

        (*!----------------------------------------
         * destructor
         *------------------------------------------*)
        destructor destroy(); override;

        (*!----------------------------------------
         * Read POST data in standard input and parse
         * it and store parsed data in body request parameter
         * and uploaded files (if any). If not file upload
         * then TNullUploadedFileCollection instance is return
         *------------------------------------------
         * @param env CGI environment variable
         * @param body instance of IList that will store
         *             parsed body parameter
         * @param uploadedFiles instance of uploaded file collection
         * @return current instance
         *------------------------------------------*)
        function parse(
            const env : ICGIEnvironment;
            const body : IList;
            out uploadedFiles : IUploadedFileCollectionWriter
        ) : IMultipartFormDataParser;
    end;

implementation

uses

    sysutils,
    iostream,
    EInvalidRequestImpl;

resourcestring

    sErrInvalidBoundary = 'Invalid multipart/form-data boundary';
    sErrInvalidMultipartFormDataName = 'Invalid multipart/form-data name';

    (*!----------------------------------------
     * constructor
     *------------------------------------------
     * @param factory factory instance to build uploaded file
     *        collection instance
     *------------------------------------------*)
    constructor TMultipartFormDataParser.create(
        const factory : IUploadedFileCollectionWriterFactory
    );
    begin
        uploadedFilesFactory := factory;
    end;

    (*!----------------------------------------
     * destructor
     *------------------------------------------*)
    destructor TMultipartFormDataParser.destroy();
    begin
        inherited destroy();
        uploadedFilesFactory := nil;
    end;

    (*!----------------------------------------------
     * extract boundary from multipart/form-data content type
     * header
     *-------- --------------------------------------
     * @param contentType content type header
     * @return boundary of multipart/form-data
     *------------------------------------------------
     * For example if we have contentType
     * 'multipart/form-data; boundary=xxx12345678'
     * it will return string 'xxx12345678'
     *-----------------------------------------------*)
    function TMultipartFormDataParser.getBoundary(const contentType : string) : string;
    const BOUNDARY = 'boundary=';
    const BOUNDARY_LEN = 9;
    var boundaryPos : integer;
    begin
        boundaryPos := pos(BOUNDARY, contentType);
        if (boundaryPos = 0) then
        begin
            //boundary string not present. Something is not right
            raise EInvalidRequest.create(sErrInvalidBoundary);
        end;

        //boundaryPos will point at beginning of 'boundary=..'
        //offset it to point to beginning of actual boundary
        boundaryPos := boundaryPos + BOUNDARY_LEN;
        //read boundary value
        result := copy(
            contentType,
            boundaryPos,
            length(contentType) - boundaryPos
        );
    end;

    (*!-------------------------------------------------------------
     * extract name from Content-Disposition
     *--------------------------------------------------------------
     * @param start starting index for extracting name
     * @param header header part
     * @return name
     *--------------------------------------------------------------
     * If we have header contains following line
     *
     * Content-Disposition: form-data; name="file2"; filename="a.html"
     * Content-Type: text/html
     *
     * start will contains value 32, start index of 'name="' substring
     * from pos() function
     * then this method will return string file2
     *--------------------------------------------------------------*)
    function TMultipartFormDataParser.extractName(const start: integer; const header : string) : string;
    var i, len:integer;
    begin
        len := length(header);
        i := start;
        result := '';
        while (header[i] <> '"') and (i<len) do
        begin
            result:= result + header[i];
        end;
    end;

    (*!-------------------------------------------------------------
     * extract variable name from Content-Disposition
     *--------------------------------------------------------------
     * @param header header part
     * @return name
     * @throws EInvalidRequest if name is not found
     *--------------------------------------------------------------
     * If we have header contains following line
     *
     * Content-Disposition: form-data; name="file2"; filename="a.html"
     * Content-Type: text/html
     *
     * then this method will return string file2 or raise exception
     * if name is not found
     *--------------------------------------------------------------*)
    function TMultipartFormDataParser.extractVariableName(const headerPart : string) : string;
    var posName : integer;
    begin
        posName := pos('name="', headerPart);
        if (posName = 0) then
        begin
            //name must be exists, if not, something is very wrong
            raise EInvalidRequest.create(sErrInvalidMultipartFormDataName);
        end;
        //6= length of 'name="'
        result := extractName(posName + 6, headerPart);
    end;

    (*!----------------------------------------
     * parse data in string store parsed data in body request parameter
     * and uploaded files (if any).
     *------------------------------------------
     * @param actualData actual data to parse
     * @param body instance of IList that will store
     *             parsed body parameter
     * @param uploadedFiles instance of uploaded file collection
     *-------------------------------------------
     * Example of actualData
     *
     * Content-Disposition: form-data; name="text"
     * \n\n
     * text default
     *
     * or
     * Content-Disposition: form-data; name="photo"; filename="shell300x300.jpg"
     * Content-Type: image/jpeg
     * \n\n
     * [binary data]
     *------------------------------------------*)
    procedure TMultipartFormDataParser.parseData(
        const actualData : string;
        const body : IList;
        const uploadedFiles : IUploadedFileCollectionWriter
    );
    var splittedData : TStringArray;
        headerPart, dataPart, delimiter, varName : string;
        originalFilename, contentType : string;
        posFilename, posContentType : integer;
    begin
        delimiter := #10#10;
        //split header and data.
        //header will be in splittedData[0] and data splittedData[1]
        splittedData := actualData.split([ delimiter ]);
        headerPart := splittedData[0];
        dataPart := splittedData[1];

        //for multipart/form-data, 'Content-Disposition' always 'form-data'
        //so we can just simply read 'name'
        varName := extractVariableName(headerPart);

        posFilename := pos('filename="', headerPart);
        if (posFilename > 0) then
        begin
            //if we get here it means we handle a file upload
            //10= length of 'filename="'
            originalFilename := extractName(posFilename + 10, headerPart);

            //extract contentType (if any)
            contentType := 'application/octet-stream';
            posContentType := pos('content-type:', lowerCase(headerPart));
            if (posContentType > 0) then
            begin
                contentType := copy(headerPart, posContentType + 13, length(headerPart));
                contentType := trim(contentType.split([';'])[0]);
            end;

            uploadedFiles.add(
                varName,
                dataPart,
                contentType,
                originalFilename
            );
        end else
        begin
            //if we get here it means we handle ordinary input
            body.add(varName, dataPart);
        end;
    end;

    (*!----------------------------------------
     * Read POST data in standard input and parse
     * it and store parsed data in body request parameter
     * and uploaded files (if any).
     *------------------------------------------
     * @param inputStream std input stream
     * @param body instance of IList that will store
     *             parsed body parameter
     * @param uploadedFiles instance of uploaded file collection
     * @param contentLength content length of request payload
     * @param boundary boundary of multipart/form-data
     *-------------------------------------------
     * Example of POST data with boundary of 'xxx12345678' s
     *
     * --xxx12345678
     * Content-Disposition: form-data; name="text"
     * \r\n
     * text default
     * --xxx12345678
     * Content-Disposition: form-data; name="file1"; filename="a.txt"
     * Content-Type: text/plain
     * \r\n
     * Content of a.txt.
     *
     * --xxx12345678
     * Content-Disposition: form-data; name="file2"; filename="a.html"
     * Content-Type: text/html
     * \r\n
     * <!DOCTYPE html><title>Content of a.html.</title>
     *
     * --xxx12345678--
     * @link : https://stackoverflow.com/questions/4238809/example-of-multipart-form-data
     * @link : https://tools.ietf.org/html/rfc7578
     *------------------------------------------
     * Instead of read all standard input and collecting
     * them as one big string and then parse them,
     * we will read std input and parse data as soon as we
     * found matching boundary
     *------------------------------------------*)
    procedure TMultipartFormDataParser.readAndParseInputStream(
        const inputStream : TStream;
        const body : IList;
        const uploadedFiles : IUploadedFileCollectionWriter;
        const contentLength : integer;
        const boundary : string
    ) : IMultipartFormDataParser;
    const BUFFER_SIZE = 8 * 1024;
    var totalRead, accumulatedRead : integer;
        accumulatedBuffer, buffer, actualData : string;
        boundaryPos, boundaryLen : integer;
        matchingBoundary, isLastBoundary : boolean;
    begin
        setLength(buffer, BUFFER_SIZE);
        accumulatedBuffer := '';
        totalRead := 0;
        accumulatedRead := 0;
        matchingBoundary := false;
        //-- character is requirement in RFC 7578 Section 4.1
        boundaryLen := length('--' + boundary);
        isLastBoundary := false;
        repeat
            totalRead := inputStream.read(buffer[1], BUFFER_SIZE);
            if (totalRead < BUFFER_SIZE) then
            begin
                //this must be last data
                setLength(buffer, totalRead);
            end;
            accumulatedRead := accumulatedRead + totalRead;
            accumulatedBuffer := accumulatedBuffer + buffer;
            boundaryPos := pos('--' + boundary, accumulatedBuffer);
            if (boundaryPos > 0) then
            begin
                //boundary is found, test further if this boundary that mark
                //beginning of data or end of data
                if (matchingBoundary) then
                begin
                    //if we get here then this marks end of data
                    //actual data will be from start of string until begining of boundary
                    actualData := copy(accumulatedBuffer, 1, boundaryPos);
                    parseData(actualData, body, uploadedFiles);

                    //remove processed string + boundary from accumulatedBuffer
                    delete(accumulatedBuffer, 1, boundaryPos + boundaryLen);
                end else
                begin
                    //if we get here then this marks beginning of data
                    matchingBoundary := true;
                    //remove boundary from accumulatedBuffer so they will not be matched
                    //in next iteration
                    delete(accumulatedBuffer, boundaryPos, boundaryLen);
                end;

                //check if this is last boundary
                //-- at last is requirement of RFC 7578 Section 4.1
                isLastBoundary := (pos('--' + boundary + '--', accumulatedBuffer) > 0);

            end;
        until isLastBoundary or (totalRead <= 0) or (accumulatedRead >= contentLength);
    end;

    (*!----------------------------------------
     * Read POST data in standard input and parse
     * it and store parsed data in body request parameter
     * and uploaded files (if any).
     *------------------------------------------
     * @param env CGI environment variable
     * @param body instance of IList that will store
     *             parsed body parameter
     * @param uploadedFiles instance of uploaded file collection
     * @return current instance
     *------------------------------------------*)
    function TMultipartFormDataParser.parse(
        const env : ICGIEnvironment;
        const body : IList;
        out uploadedFiles : IUploadedFileCollectionWriter
    ) : IMultipartFormDataParser;
    var inputStream : TIOStream;
        boundary : string;
    begin
        boundary := getBoundary(env.contentType());
        inputStream := TIOStream.create(iosInput);
        uploadedFiles := uploadedFilesFactory.createCollectionWriter();
        try
            readAndParseInputStream(
                inputStream,
                body,
                uploadedFiles,
                env.intContentLength(),
                boundary
            );
            result := self;
        finally
            freeAndNil(inputStream);
        end;
    end;
end.
