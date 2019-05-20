{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiEndRequest;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * End Request record (FCGI_BEGIN_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiEndRequest = class(TFcgiRecord)
    private
        fProtocolStatus : byte;
        fAppStatus : cardinal;
    public
        constructor create(
            const requestId : word;
            const protocolStatus : byte = FCGI_REQUEST_COMPLETE;
            const appStatus : cardinal = 0
        );

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

    constructor TFcgiEndRequest.create(
        const requestId : word;
        const protocolStatus : byte = FCGI_REQUEST_COMPLETE;
        const appStatus : cardinal = 0;
    );
    begin
        inherited create(FCGI_END_REQUEST, requestId);
        fProtocolStatus := protocolStatus;
        fAppStatus := appStatus;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiEndRequest.write(const stream : IStreamAdapter) : integer;
    var endRequestRec : FCGI_EndRequestRecord;
        bytesToWrite, bytesWritten : integer;
    begin
        fillChar(endRequestRec, sizeOf(FCGI_EndRequestRecord), 0);
        endRequestRec.header.version:= fVersion;
        endRequestRec.header.reqtype:= fType;
        endRequestRec.header.contentLength:= NtoBE(fContentLength);
        endRequestRec.header.paddingLength:= fPaddingLength;
        endRequestRec.header.requestId:= NToBE(fRequestId);
        endRequestRec.body.protocolStatus := FCGI_REQUEST_COMPLETE;
        endRequestRec.body.appStatusB0 := appStatus and $ff;
        endRequestRec.body.appStatusB1 := (appStatus shr 8) and $ff;
        endRequestRec.body.appStatusB2 := (appStatus shr 16) and $ff;
        endRequestRec.body.appStatusB3 := (appStatus shr 24) and $ff;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(endRequestRec, bytesToWrite);
    end;
end.
