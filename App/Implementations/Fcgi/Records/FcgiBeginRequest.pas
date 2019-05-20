{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiBeginRequest;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!-----------------------------------------------
     * Begin Request record (FCGI_BEGIN_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiBeginRequest = class(TFcgiRecord)
    private
        fRole : byte;
        fFlags : byte;
    public
        constructor create(const requestId : word; const role : byte; const flag: byte);

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

    constructor TFcgiBeginRequest.create(
        const requestId : word;
        const role : byte = FCGI_RESPONDER;
        const flag: byte = 0
    );
    begin
        inherited create(FCGI_BEGIN_REQUEST, requestId);
        fRole := role;
        fFlags := flag;
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiBeginRequest.write(const stream : IStreamAdapter) : integer;
    var beginRequestRec : FCGI_BeginRequestRecord;
        bytesToWrite : integer;
    begin
        fillChar(beginRequestRec, sizeOf(FCGI_BeginRequestRecord), 0);
        beginRequestRec.header.version:= fVersion;
        beginRequestRec.header.reqtype:= fType;
        beginRequestRec.header.contentLength:= NtoBE(fContentLength);
        beginRequestRec.header.paddingLength:= fPaddingLength;
        beginRequestRec.header.requestId:= NToBE(fRequestId);
        beginRequestRec.body.role := fRole;
        beginRequestRec.body.flags := fFlags;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(beginRequestRec, bytesToWrite);
        result := bytesToWrite;
    end;
end.
