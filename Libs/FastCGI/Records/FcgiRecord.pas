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
        fContentLength : word;

        fPaddingLength : byte;
        fReserved : byte;

        fContentData : IStreamAdapter;
        fPaddingData : shortstring;

        (*!------------------------------------------------
         * calculate number of bytes to write per record
         *-----------------------------------------------
         * @param len, current data length
         * @param excess, current data length excess
         * @return number of bytes actually written
         *-----------------------------------------------*)
        function getPaddingToWrite(const len: word) : byte;

        (*!------------------------------------------------
         * write record data to stream
         *-----------------------------------------------
         * @param stream, stream instance where to write
         * @return number of bytes actually written
         *-----------------------------------------------*)
        function writeRecord(const stream : IStreamAdapter; const data : pointer; const size:integer) : integer;
    public
        constructor create(
            const stream : IStreamAdapter;
            const aType : byte = FCGI_UNKNOWN_TYPE;
            const aRequestId : word = FCGI_NULL_REQUEST_ID
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
        function write(const stream : IStreamAdapter) : integer; virtual; abstract;
    end;

implementation

    constructor TFcgiRecord.create(
        const stream : IStreamAdapter;
        const aType : byte = FCGI_UNKNOWN_TYPE;
        const aRequestId : word = FCGI_NULL_REQUEST_ID
    );
    begin
        fVersion := FCGI_VERSION_1;
        fType := aType;
        fRequestId := aRequestId;
        fReserved := 0;
        fContentLength := 0;
        fPaddingLength := 0;
        fContentData := stream;
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
        result := fContentLength;
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
    begin
        result := FCGI_HEADER_LEN + fContentLength + fPaddingLength;
    end;

    (*!------------------------------------------------
     * calculate number of bytes to write per record
     *-----------------------------------------------
     * @param len, current data length
     * @param excess, current data length excess
     * @return number of bytes actually written
     *-----------------------------------------------*)
    function TFcgiRecord.getPaddingToWrite(const len: word) : byte;
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
     * write record data to stream
     *-----------------------------------------------
     * @param stream, stream instance where to write
     * @return number of bytes actually written
     *-----------------------------------------------*)
    function TFcgiRecord.writeRecord(const stream : IStreamAdapter; const data : pointer; const size:integer) : integer;
    const zeroByte = 0;
    var headerRec : FCGI_Header;
    begin
        fContentLength := size;
        fPaddingLength := getPaddingToWrite(fContentLength);
        fillChar(headerRec, sizeof(FCGI_Header), zeroByte);
        headerRec.version := fVersion;
        headerRec.reqtype := fType;
        headerRec.paddingLength := fPaddingLength;
        headerRec.contentLength := NtoBE(fContentLength);
        headerRec.requestId := NToBE(fRequestID);
        stream.writeBuffer(headerRec, sizeof(FCGI_Header));
        stream.writeBuffer(data, size);
        stream.writeBuffer(zeroByte, fPaddingLength);
    end;
end.
