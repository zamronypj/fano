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

        fContentData : string;
        fPaddingData : shortstring;

    public
        constructor create(
            const aType : byte = FCGI_UNKNOWN_TYPE;
            const aRequestId : word = FCGI_NULL_REQUEST_ID
        );

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
    * calculate total record data size
    *-----------------------------------------------
    * @return number of bytes of current record
    *-----------------------------------------------*)
    function TFcgiRecord.getRecordSize() : integer;
    begin
        result := FCGI_HEADER_LEN + fContentLength + fPaddingLength;
    end;
end.
