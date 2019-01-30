{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RequestImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    EnvironmentIntf,
    RequestIntf,
    ListIntf,
    MultipartFormDataParserIntf,
    KeyValueTypes,
    UploadedFileIntf,
    UploadedFileCollectionIntf,
    UploadedFileCollectionWriterIntf,
    StdInReaderIntf;

const

    DEFAULT_MAX_POST_SIZE = 8 * 1024 * 1024;
    DEFAULT_MAX_UPLOAD_SIZE = 2 * 1024 * 1024;

type

    (*!------------------------------------------------
     * basic class having capability as
     * HTTP request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRequest = class(TInterfacedObject, IRequest)
    private
        webEnvironment : ICGIEnvironment;
        queryParams : IList;
        cookieParams : IList;
        bodyParams : IList;
        uploadedFiles: IUploadedFileCollection;
        uploadedFilesWriter: IUploadedFileCollectionWriter;
        multipartFormDataParser : IMultipartFormDataParser;
        stdInReader : IStdInReader;

        (*!------------------------------------------------
         * maximum POST data size in bytes
         *-------------------------------------------------*)
        maximumPostSize : int64;

        (*!------------------------------------------------
         * maximum single uploaded file size in bytes
         *-------------------------------------------------*)
        maximumUploadedFileSize : int64;

        procedure raiseExceptionIfPostDataTooBig(const contentLength : int64);

        procedure clearParams(const params : IList);

        procedure initParamsFromString(
            const data : string;
            const hashInst : IList
        );

        procedure initPostBodyParamsFromStdInput(
            const env : ICGIEnvironment;
            const body : IList
        );

        procedure initBodyParamsFromStdInput(
            const env : ICGIEnvironment;
            const body : IList
        );

        procedure initQueryParamsFromEnvironment(
            const env : ICGIEnvironment;
            const query : IList
        );

        procedure initCookieParamsFromEnvironment(
            const env : ICGIEnvironment;
            const cookies : IList
        );

        procedure initParamsFromEnvironment(
            const env : ICGIEnvironment;
            const query : IList;
            const cookies : IList;
            const body : IList
        );

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParam(
            const src :IList;
            const key: string;
            const defValue : string = ''
        ) : string;

    public
        constructor create(
            const env : ICGIEnvironment;
            const query : IList;
            const cookies : IList;
            const body : IList;
            const multipartFormDataParserInst : IMultipartFormDataParser;
            const stdInputReader : IStdInReader;
            const maxPostSize : int64 = DEFAULT_MAX_POST_SIZE;
            const maxUploadSize : int64 = DEFAULT_MAX_UPLOAD_SIZE
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getQueryParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all query params
         *-------------------------------------------------
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getQueryParams() : IList;

        (*!------------------------------------------------
         * get single cookie param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getCookieParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all query params
         *-------------------------------------------------
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getCookieParams() : IList;

        (*!------------------------------------------------
         * get request body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParsedBodyParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all request body data
         *-------------------------------------------------
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getParsedBodyParams() : IList;

        (*!------------------------------------------------
         * get request uploaded file by name
         *-------------------------------------------------
         * @param string key name of key
         * @return instance of IUploadedFile or nil if is not
         *         exists
         *------------------------------------------------*)
        function getUploadedFile(const key: string) : IUploadedFileArray;

        (*!------------------------------------------------
         * get all uploaded files
         *-------------------------------------------------
         * @return IUploadedFileCollection or nil if no file
         *         upload
         *------------------------------------------------*)
        function getUploadedFiles() : IUploadedFileCollection;

        (*!------------------------------------------------
         * test if current request is comming from AJAX request
         *-------------------------------------------------
         * @return true if ajax request
         *------------------------------------------------*)
        function isXhr() : boolean;
    end;

implementation

uses

    sysutils,
    UrlHelpersImpl,
    EInvalidRequestImpl;

resourcestring

    sErrExceedMaxPostSize = 'POST size (%d) exceeds maximum allowable POST size (%d)';

    constructor TRequest.create(
        const env : ICGIEnvironment;
        const query : IList;
        const cookies : IList;
        const body : IList;
        const multipartFormDataParserInst : IMultipartFormDataParser;
        const stdInputReader : IStdInReader;
        const maxPostSize : int64 = DEFAULT_MAX_POST_SIZE;
        const maxUploadSize : int64 = DEFAULT_MAX_UPLOAD_SIZE
    );
    begin
        webEnvironment := env;
        queryParams := query;
        cookieParams := cookies;
        bodyParams := body;
        multipartFormDataParser := multipartFormDataParserInst;
        stdInReader := stdInputReader;
        uploadedFiles := nil;
        uploadedFilesWriter := nil;

        maximumPostSize := maxPostSize;
        maximumUploadedFileSize := maxUploadSize;

        initParamsFromEnvironment(
            webEnvironment,
            queryParams,
            cookieParams,
            bodyParams
        );

    end;

    destructor TRequest.destroy();
    begin
        inherited destroy();
        clearParams(queryParams);
        clearParams(cookieParams);
        clearParams(bodyParams);
        webEnvironment := nil;
        queryParams := nil;
        cookieParams := nil;
        bodyParams := nil;
        uploadedFiles := nil;
        uploadedFilesWriter := nil;
        multipartFormDataParser := nil;
    end;

    procedure TRequest.clearParams(const params : IList);
    var i, len : integer;
        param : PKeyValue;
    begin
        len := params.count();
        for i:= len-1 downto 0 do
        begin
            param := params.get(i);
            dispose(param);
            params.delete(i);
        end;
    end;

    procedure TRequest.initParamsFromString(
        const data : string;
        const hashInst : IList
    );
    var arrOfQryStr, keyvalue : TStringArray;
        i, len, lenKeyValue : integer;
        param : PKeyValue;
    begin
        arrOfQryStr := data.split(['&']);
        len := length(arrOfQryStr);
        for i:= 0 to len-1 do
        begin
            keyvalue := arrOfQryStr[i].split('=');
            lenKeyValue := length(keyvalue);
            if (lenKeyValue = 2) then
            begin
                new(param);
                param^.key := keyvalue[0];
                param^.value := (keyvalue[1]).urlDecode();
                hashInst.add(param^.key, param);
            end;
        end;
    end;

    procedure TRequest.initQueryParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IList
    );
    begin
        initParamsFromString(env.queryString(), query);
    end;

    procedure TRequest.initCookieParamsFromEnvironment(
        const env : ICGIEnvironment;
        const cookies : IList
    );
    begin
        initParamsFromString(env.httpCookie(), cookies);
    end;

    procedure TRequest.raiseExceptionIfPostDataTooBig(const contentLength : int64);
    begin
        if (contentLength > maximumPostSize) then
        begin
            {---------------------------------------------------
            we abort, but Apache requires app to read ALL POST data
            or close STDIN file handle eventhough not using it. Otherwise in
            Apache we will get AH00574 error. Here we just read it and discard
            -----------------------------------------------------}
            stdInReader.readStdIn(contentLength);
            raise EInvalidRequest.createFmt(
                sErrExceedMaxPostSize,
                [ contentLength, maximumPostSize ]
            );
        end;
    end;

    procedure TRequest.initPostBodyParamsFromStdInput(
        const env : ICGIEnvironment;
        const body : IList
    );
    var contentLength : int64;
        contentType, bodyStr : string;
        param : PKeyValue;
    begin
        contentLength := env.intContentLength();
        raiseExceptionIfPostDataTooBig(contentLength);

        contentType := lowerCase(env.contentType());
        if (contentType = 'application/x-www-form-urlencoded') then
        begin
            //read STDIN
            bodyStr := stdInReader.readStdIn(contentLength);
            initParamsFromString(bodyStr, body);
        end
        else if (pos('multipart/form-data', contentType) > 0) then
        begin
            multipartFormDataParser.parse(env, body, uploadedFilesWriter);
            uploadedFiles := uploadedFilesWriter as IUploadedFileCollection;
        end else
        begin
            //read STDIN
            bodyStr := stdInReader.readStdIn(contentLength);

            //if POST but different contentType save it as it is
            //with its contentType as key
            new(param);
            param^.key := contentType;
            param^.value := bodyStr;
            body.add(param^.key, param);
        end;
    end;

    procedure TRequest.initBodyParamsFromStdInput(
        const env : ICGIEnvironment;
        const body : IList
    );
    begin
        if (env.requestMethod() = 'POST') then
        begin
            initPostBodyParamsFromStdInput(env, body);
        end;
    end;

    procedure TRequest.initParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IList;
        const cookies : IList;
        const body : IList
    );
    begin
        initQueryParamsFromEnvironment(env, query);
        initCookieParamsFromEnvironment(env, cookies);
        initBodyParamsFromStdInput(env, bodyParams);
    end;

    (*!------------------------------------------------
     * get single param value by its name
     *-------------------------------------------------
     * @param IList src hash list instance
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getParam(
        const src : IList;
        const key: string;
        const defValue : string = ''
    ) : string;
    var qry : PKeyValue;
    begin
        qry := src.find(key);
        if (qry = nil) then
        begin
            result := defValue;
        end else
        begin
            result := qry^.value;
        end;
    end;

    (*!------------------------------------------------
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getQueryParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(queryParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request query strings data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TRequest.getQueryParams() : IList;
    begin
        result := queryParams;
    end;

    (*!------------------------------------------------
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getCookieParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(cookieParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request cookie data
     *-------------------------------------------------
     * @return list of request cookies parameters
     *------------------------------------------------*)
    function TRequest.getCookieParams() : IList;
    begin
        result := cookieParams;
    end;

    (*!------------------------------------------------
     * get request body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getParsedBodyParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(bodyParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return list of request body parameters
     *------------------------------------------------*)
    function TRequest.getParsedBodyParams() : IList;
    begin
        result := bodyParams;
    end;

    (*!------------------------------------------------
     * get request uploaded file by name
     *-------------------------------------------------
     * @param string key name of key
     * @return instance of IUploadedFileArray or nil if is not
     *         exists
     *------------------------------------------------*)
    function TRequest.getUploadedFile(const key: string) : IUploadedFileArray;
    begin
        result := uploadedFiles.getUploadedFile(key);
    end;

    (*!------------------------------------------------
     * get all uploaded files
     *-------------------------------------------------
     * @return IUploadedFileCollection
     *------------------------------------------------*)
    function TRequest.getUploadedFiles() : IUploadedFileCollection;
    begin
        result := uploadedFiles;
    end;

    (*!------------------------------------------------
     * test if current request is coming from AJAX request
     *-------------------------------------------------
     * @return true if ajax request false otherwise
     *------------------------------------------------*)
    function TRequest.isXhr() : boolean;
    begin
        result := (webEnvironment.env('HTTP_X_REQUESTED_WITH') = 'XMLHttpRequest');
    end;
end.
