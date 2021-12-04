{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit LnetStdOutWriterImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SysUtils,
    StreamAdapterIntf,
    StdOutIntf,
    StreamStdOutImpl,
    lhttp,
    LnetResponseAwareIntf;

type

    (*!-----------------------------------------------
     * IStdOut implementation having capability to write
     * response with LNet TLHTTPServer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLnetStdOutWriter = class(TStreamStdOut, ILnetResponseAware)
    private
        fResponse : TOutputItem;
    protected

        (*!------------------------------------------------
         * write string to stream and
         *-----------------------------------------------
         * @param stream, stream to write
         * @param str, string to write
         * @return current instance
         *-----------------------------------------------*)
        function writeStream(const stream : IStreamAdapter; const str : string) : IStdOut; override;
    public
        (*!------------------------------------------------
         * get TLHttpServer response connection
         *-----------------------------------------------
         * @return connection
         *-----------------------------------------------*)
        function getResponse() : TOutputItem;

        (*!------------------------------------------------
         * set TLHttpServer response connection
         *-----------------------------------------------*)
        procedure setResponse(aresponse : TOutputItem);

        property response : TOutputItem read getResponse write setResponse;
    end;

implementation

uses

    MappedMemoryStreamImpl,
    NullMemoryDeallocatorImpl,
    EInvalidRequestImpl;

const

    HEADER_SEPARATOR_STR = LineEnding + LineEnding;
    HEADER_SEPARATOR_LEN = length(HEADER_SEPARATOR_STR);

    (*!------------------------------------------------
     * get TLHttpServer response connection
     *-----------------------------------------------
     * @return connection
     *-----------------------------------------------*)
    function TLnetStdOutWriter.getResponse() : TOutputItem;
    begin
        result := fResponse;
    end;

    (*!------------------------------------------------
     * set TLHttpServer response connection
     *-----------------------------------------------*)
    procedure TLnetStdOutWriter.setResponse(aresponse : TOutputItem);
    begin
        fResponse := aresponse;
    end;

    (*!------------------------------------------------
     * write string to STDOUT stream
     *-----------------------------------------------
     * @param stream, stream to write
     * @param str, string to write
     * @return current instance
     *-----------------------------------------------*)
    function TLnetStdOutWriter.writeStream(const stream : IStreamAdapter; const str : string) : IStdOut;
    begin

    end;

end.
