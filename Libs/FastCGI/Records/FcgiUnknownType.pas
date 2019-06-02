{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiUnknownType;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Unknown type record (FCGI_UNKNOWN_TYPE)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiUnknownType = class(TFcgiRecord)
    private
        fUnknownType : byte;
    public
        constructor create(const requestId : word);

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiUnknownType.create(const requestId : word; const unknownType : byte);
    begin
        inherited create(FCGI_UNKNOWN_TYPE, requestId);
        fUnknownType := unknownType;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiUnknownType.write(const stream : IStreamAdapter) : integer;
    var rec : FCGI_UnknownTypeRecord;
        bytesToWrite : integer;
    begin
        fillChar(rec, sizeOf(FCGI_UnknownTypeRecord), 0);
        rec.header.version:= fVersion;
        rec.header.reqtype:= fType;
        rec.header.contentLength:= NtoBE(fContentLength);
        rec.header.paddingLength:= fPaddingLength;
        rec.header.requestId:= NToBE(fRequestId);
        rec.body._type := fUnknownType;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(endRequestRec, bytesToWrite);
        result := bytesToWrite;
    end;
end.
