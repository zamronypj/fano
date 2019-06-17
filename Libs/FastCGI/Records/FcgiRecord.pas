{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRecord;

interface

{$MODE OBJFPC}
{$H+}

uses

    fastcgi,
    StreamAdapterIntf,
    FcgiRecordIntf;

type

    (*!-----------------------------------------------
     * Base FastCGI record
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiRecord = class(TInterfacedObject, IFcgiRecord)
    protected
        fVersion : byte;
        fType : byte;
        //two bytes with big endian order
        fRequestId : word;
        fContentData : IStreamAdapter;

        (*!------------------------------------------------
         * calculate number of bytes of padding to write per record
         *-----------------------------------------------
         * @param len, current data length
         * @return number of bytes of padding required
         *-----------------------------------------------*)
        function getPaddingLength(const len: word) : byte;
    public
        constructor create(
            const aVersion : byte;
            const aType : byte;
            const aRequestId : word;
            const dataStream : IStreamAdapter
        );

        constructor createFromStream(
            const srcStream : IStreamAdapter;
            const dataStream : IStreamAdapter
        );

        destructor destroy(); override;

        (*!------------------------------------------------
         * get current record type
         *-----------------------------------------------
         * @return type of record
         *-----------------------------------------------*)
        function getType() : byte;

        (*!------------------------------------------------
         * get request id
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function getRequestId() : word;

        (*!------------------------------------------------
         * get content length
         *-----------------------------------------------
         * @return content length
         *-----------------------------------------------*)
        function getContentLength() : word;

        (*!------------------------------------------------
         * get content of record data
         *-----------------------------------------------
         * @return data as stream
         *-----------------------------------------------*)
        function data() : IStreamAdapter;

        (*!------------------------------------------------
         * calculate total record data size
         *-----------------------------------------------
         * @return number of bytes of current record
         *-----------------------------------------------*)
        function getRecordSize() : integer;

        (*!------------------------------------------------
         * write record data to stream
         *-----------------------------------------------
         * @param stream, stream instance where to write
         * @return number of bytes actually written
         *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer;
    end;

implementation

    constructor TFcgiRecord.create(
        const aVersion : byte;
        const aType : byte;
        const aRequestId : word;
        const dataStream : IStreamAdapter
    );
    begin
        fVersion := aVersion;
        fType := aType;
        fRequestId := aRequestId;
        fContentData := dataStream;
    end;

    constructor TFcgiRecord.createFromStream(
        const srcStream : IStreamAdapter;
        const dataStream : IStreamAdapter
    );
    var header : FCGI_Header;
        contentLength : word;
    begin
        stream.readBuffer(header, sizeof(FCGI_Header));
        fVersion := header.version;
        fType := header.reqtype;
        fRequestId := BEtoN(header.requestID);
        contentLength := BEtoN(header.contentLength);
        fContentData := dataStream;
        srcStream.readStream(fContentData, contentLength);
        srcStream.seek(header.paddingLength, FROM_CURRENT);
    end;

    destructor TFcgiRecord.destroy();
    begin
        inherited destroy();
        fContentData := nil;
    end;

    (*!------------------------------------------------
     * get current record type
     *-----------------------------------------------
     * @return type of record
     *-----------------------------------------------*)
    function TFcgiRecord.getType() : byte;
    begin
        result := fType;
    end;

    (*!------------------------------------------------
     * get request id
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiRecord.getRequestId() : word;
    begin
        result := fRequestId;
    end;

    (*!------------------------------------------------
     * get content length
     *-----------------------------------------------
     * @return content length
     *-----------------------------------------------*)
    function TFcgiRecord.getContentLength() : word;
    begin
        result := word(fContentData.size());
    end;

    (*!------------------------------------------------
     * get content record data
     *-----------------------------------------------
     * @return stream
     *-----------------------------------------------*)
    function TFcgiRecord.data() : IStreamAdapter;
    begin
        result := fContentData;
    end;

    (*!------------------------------------------------
    * calculate total record data size
    *-----------------------------------------------
    * @return number of bytes of current record
    *-----------------------------------------------*)
    function TFcgiRecord.getRecordSize() : integer;
    var contentLength : word;
        paddingLength : byte;
    begin
        contentlength := getContentLength();
        paddingLength := getPaddingLength(contentLength);
        result := FCGI_HEADER_LEN + contentLength + paddingLength;
    end;

    (*!------------------------------------------------
     * calculate number of bytes to write per record
     *-----------------------------------------------
     * @param len, current data length
     * @param excess, current data length excess
     * @return number of bytes actually written
     *-----------------------------------------------*)
    function TFcgiRecord.getPaddingLength(const len: word) : byte;
    begin
        if ((len mod FCGI_HEADER_LEN) = 0) then
        begin
            result := 0;
        end else
        begin
            result := FCGI_HEADER_LEN - (len mod FCGI_HEADER_LEN);
        end;
    end;

    (*!------------------------------------------------
     * write record data to destination stream
     *-----------------------------------------------
     * @param dstStream, stream instance where to write
     * @return number of bytes actually written
     *-----------------------------------------------*)
    function TFcgiRecord.write(const dstStream : IStreamAdapter) : integer;
    var headerRec : FCGI_Header;
        contentLength : word;
        padding : byte;
    begin
        contentlength := getContentLength();

        headerRec.version := fVersion;
        headerRec.reqtype := fType;
        headerRec.requestId := NToBE(fRequestID);
        headerRec.contentLength := NtoBE(contentlength);
        headerRec.paddingLength := getPaddingLength(contentLength);
        headerRec.reserved := 0;

        //write header part
        stream.writeBuffer(headerRec, sizeof(FCGI_Header));
        //write data part
        stream.writeStream(fContentData);
        //write padding part if any
        if (headerRec.paddingLength > 0) then
        begin
            padding := 0;
            stream.writeBuffer(padding, headerRec.paddingLength);
        end;

        result := getRecordSize();
    end;
end.
