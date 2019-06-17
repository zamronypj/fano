{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiEndRequest;

interface

{$MODE OBJFPC}
{$H+}

uses

    fastcgi,
    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * End Request record (FCGI_END_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiEndRequest = class(TFcgiRecord)
    private
        fProtocolStatus : byte;
        fAppStatus : cardinal;
    public
        constructor create(
            const dataStream : IStreamAdapter;
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

    constructor TFcgiEndRequest.create(
        const stream : IStreamAdapter;
        const requestId : word;
        const protocolStatus : byte = FCGI_REQUEST_COMPLETE;
        const appStatus : cardinal = 0
    );
    begin
        inherited create(stream, FCGI_END_REQUEST, requestId);
        fProtocolStatus := protocolStatus;
        fAppStatus := appStatus;
    end;

    constructor TFcgiEndRequest.createFromStream(const stream : IStreamAdapter);
    var reqBody : FCGI_EndRequestBody;
    begin
        //skip header as parent class already read it
        stream.seek(sizeof(FCGI_Header));
        stream.readBuffer(reqBody, sizeof(FCGI_EndRequestBody));
        fProtocolStatus := recBody.protocolStatus;
        fAppStatus := ((recBody.appStatusB3 shl 24) and $ff) or
                    ((recBody.appStatusB2 shl 16) and $ff) or
                    ((recBody.appStatusB1 shl 8) and $ff) or
                    (recBody.appStatusB0 and $ff);
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiEndRequest.write(const stream : IStreamAdapter) : integer;
    var endRequestRec : FCGI_EndRequestRecord;
        bytesToWrite : integer;
    begin
        fillChar(endRequestRec, sizeOf(FCGI_EndRequestRecord), 0);
        endRequestRec.header.version:= fVersion;
        endRequestRec.header.reqtype:= fType;
        endRequestRec.header.contentLength:= NtoBE(fContentLength);
        endRequestRec.header.paddingLength:= fPaddingLength;
        endRequestRec.header.requestId:= NToBE(fRequestId);
        endRequestRec.body.protocolStatus := fProtocolStatus;
        endRequestRec.body.appStatusB0 := fAppStatus and $ff;
        endRequestRec.body.appStatusB1 := (fAppStatus shr 8) and $ff;
        endRequestRec.body.appStatusB2 := (fAppStatus shr 16) and $ff;
        endRequestRec.body.appStatusB3 := (fAppStatus shr 24) and $ff;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(endRequestRec, bytesToWrite);
        result := bytesToWrite;
    end;
end.
