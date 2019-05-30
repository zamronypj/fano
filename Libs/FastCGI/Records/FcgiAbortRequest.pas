{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiAbortRequest;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Abort Request record (FCGI_ABORT_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiAbortRequest = class(TFcgiRecord)
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

    constructor TFcgiAbortRequest.create(const requestId : word);
    begin
        inherited create(FCGI_ABORT_REQUEST, requestId);
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiAbortRequest.write(const stream : IStreamAdapter) : integer;
    var abortRequestRec : FCGI_Header;
        bytesToWrite : integer;
    begin
        fillChar(abortRequestRec, sizeOf(FCGI_Header), 0);
        abortRequestRec.version:= fVersion;
        abortRequestRec.reqtype:= fType;
        abortRequestRec.contentLength:= NtoBE(fContentLength);
        abortRequestRec.paddingLength:= fPaddingLength;
        abortRequestRec.requestId:= NToBE(fRequestId);
        bytesToWrite := getRecordSize();
        stream.writeBuffer(endRequestRec, bytesToWrite);
        result := bytesToWrite;
    end;
end.
