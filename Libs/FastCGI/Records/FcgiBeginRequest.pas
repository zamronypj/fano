{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiBeginRequest;

interface

{$MODE OBJFPC}
{$H+}

uses

    fastcgi,
    StreamAdapterIntf,
    FcgiRecord;

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
        constructor create(
            const aVersion : byte;
            const aType : byte;
            const aRequestId : word;
            const dataStream : IStreamAdapter;
            const role : byte;
            const flag: byte
        );

        constructor create(
            const stream : IStreamAdapter;
            const requestId : word;
            const role : byte = FCGI_RESPONDER;
            const flag: byte = 0
        );

        constructor createFromStream(const srcStream : IStreamAdapter);

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

implementation


    constructor TFcgiBeginRequest.create(
        const stream : IStreamAdapter;
        const requestId : word;
        const role : byte = FCGI_RESPONDER;
        const flag: byte = 0
    );
    begin
        inherited create(stream, FCGI_BEGIN_REQUEST, requestId);
        if (stream.size() > 0) then
        begin
            //stream contain data, read from it instead
            initFromStream(stream);
        end else
        begin
            fRole := role;
            fFlags := flag;
        end;
        fContentData.seek(0);
    end;

    constructor TFcgiBeginRequest.createFromStream(
        const srcStream : IStreamAdapter;
        const dstStream : IStreamAdapter
    );
    var reqBody : FCGI_BeginRequestBody;
    begin
        inherited createFromStream(srcStream, dstStream);
        //skip header as parent class already read it
        stream.seek(sizeof(FCGI_Header));
        stream.readBuffer(reqBody, sizeof(FCGI_BeginRequestBody));
        fRole := recBody.role;
        fFlags := recBody.flags;
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
        beginRequestRec.header.requestId:= NToBE(fRequestId);
        beginRequestRec.header.contentLength:= NtoBE(fContentLength);
        beginRequestRec.header.paddingLength:= fPaddingLength;
        beginRequestRec.body.role := fRole;
        beginRequestRec.body.flags := fFlags;
        bytesToWrite := getRecordSize();
        stream.writeBuffer(beginRequestRec, bytesToWrite);
        result := bytesToWrite;
    end;
end.
