{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FcgiStdOutWriterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    StdOutIntf,
    RequestIdAwareIntf;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment and write response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdOutWriter = class(TInterfacedObject, IStdOut)
    private
        fStream : IStreamAdapter;
        fRequestIdAware : IRequestIdAware;

        (*!------------------------------------------------
         * mark end of request
         *-----------------------------------------------
         * @param stream, stream to write
         * @return current instance
         *-----------------------------------------------*)
        function writeEnd(const requestId : word; const stream : IStreamAdapter) : IStdOut;

        (*!------------------------------------------------
         * write string to FCGI_STDOUT stream and
         * mark it end of request (if markEnd is true)
         *-----------------------------------------------
         * @param stream, stream to write
         * @param str, string to write
         * @param markEnd, if true, add FCGI_END_REQUEST
         * @return current instance
         *-----------------------------------------------
         * very long string may be splitted into several
         * FCGI_STDOUT records
         *-----------------------------------------------*)
        function writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    public

        constructor create(
            const requestIdAware : IRequestIdAware;
            const astream : IStreamAdapter = nil
        );
        destructor destroy(); override;

        function setStream(const astream : IStreamAdapter) : IStdOut;

        (*!------------------------------------------------
         * write string to FCGI_STDOUT stream and
         * mark it end of request (if markEnd is true)
         *-----------------------------------------------
         * @param str, string to write
         * @return current instance
         *-----------------------------------------------*)
        function write(const str : string) : IStdOut;

        (*!------------------------------------------------
         * write string with newline to FCGI_STDOUT stream and
         * mark it end of request (if markEnd is true)
         *-----------------------------------------------
         * @param str, string to write
         * @return current instance
         *-----------------------------------------------*)
        function writeln(const str : string) : IStdOut;

    end;

implementation

uses

    fastcgi,
    classes,
    math,
    strutils,
    FcgiRecordIntf,
    FcgiStdOut,
    FcgiEndRequest,
    StreamAdapterImpl,
    NullStreamAdapterImpl;

    constructor TFcgiStdOutWriter.create(
        const requestIdAware : IRequestIdAware;
        const astream : IStreamAdapter = nil
    );
    begin
        fRequestIdAware := requestIdAware;
        fStream := astream;
    end;

    destructor TFcgiStdOutWriter.destroy();
    begin
        inherited destroy();
        fStream := nil;
    end;

    function TFcgiStdOutWriter.setStream(const astream : IStreamAdapter) : IStdOut;
    begin
        fStream := astream;
        result := self;
    end;

    (*!------------------------------------------------
     * mark end of request
     *-----------------------------------------------
     * @param stream, stream to write
     * @return current instance
     *-----------------------------------------------*)
    function TFcgiStdOutWriter.writeEnd(const requestId : word; const stream : IStreamAdapter) : IStdOut;
    var arecord : IFcgiRecord;
    begin
        arecord := TFcgiEndRequest.create(
            TStreamAdapter.create(TMemoryStream.create()),
            requestId
        );
        arecord.write(stream);
        result := self;
    end;

    (*!------------------------------------------------
     * write string to FCGI_STDOUT stream and
     * mark it end of request (if markEnd is true)
     *-----------------------------------------------
     * @param stream, stream to write
     * @param str, string to write
     * @param markEnd, if true, add FCGI_END_REQUEST
     * @return current instance
     *-----------------------------------------------
     * very long string may be splitted into several
     * FCGI_STDOUT records
     *-----------------------------------------------*)
    function TFcgiStdOutWriter.writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    const MAX_STR_PER_RECORD = 32 * 1024;
    var arecord : IFcgiRecord;
        i, totChunk, excess, len, astart, acount : integer;
        requestId : word;
    begin
        //get request id associated with current complete request
        requestId := fRequestIdAware.getRequestId();
        //split string into several shorter strings
        len := length(str);
        totChunk := len div MAX_STR_PER_RECORD;
        excess := len mod MAX_STR_PER_RECORD;
        if (excess > 0) then
        begin
            inc(totChunk);
        end;

        astart := 1;
        for i := 0 to totChunk-1 do
        begin
            acount := min(MAX_STR_PER_RECORD, len);
            arecord := TFcgiStdOut.create(
                TStreamAdapter.create(TStringStream.create(midStr(str, astart, acount))),
                requestId,
            );
            arecord.write(stream);
            inc(astart, acount);
        end;

        writeEnd(requestId, stream);
        result:= self;
    end;

    (*!------------------------------------------------
     * write string to FCGI_STDOUT stream and
     * mark it end of request (if markEnd is true)
     *-----------------------------------------------
     * @param str, string to write
     * @return current instance
     *-----------------------------------------------*)
    function TFcgiStdOutWriter.write(const str : string) : IStdOut;
    begin
        result := writeStream(fStream, str);
    end;

    (*!------------------------------------------------
     * write string with newline to FCGI_STDOUT stream and
     * mark it end of request (if markEnd is true)
     *-----------------------------------------------
     * @param str, string to write
     * @return current instance
     *-----------------------------------------------*)
    function TFcgiStdOutWriter.writeln(const str : string) : IStdOut;
    begin
        result := writeStream(fStream, str + LineEnding);
    end;
end.
