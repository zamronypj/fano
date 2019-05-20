{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiRecord;

interface

{$MODE OBJFPC}
{$H+}

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

        function setContentData(const buffer : pointer; const bufferSize : int64) : IFcgiRecord;
        function packPayload() : string; virtual;
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
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; virtual; abstract;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiRecord.create(
        const aType : byte = FCGI_UNKNOWN_TYPE;
        const requestId : word = FCGI_NULL_REQUEST_ID
    );
    begin
        fVersion := FCGI_VERSION_1;
        fType := aType;
        fRequestId := requestId;
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
end.
