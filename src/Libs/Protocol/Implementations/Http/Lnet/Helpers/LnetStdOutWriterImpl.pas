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

    StreamAdapterIntf,
    StdOutIntf,
    StreamStdOutImpl,
    LnetCgiOutputImpl,
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
        fResponse : TLnetCGIOutput;
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
        function getResponse() : TLnetCGIOutput;

        (*!------------------------------------------------
         * set TLHttpServer response connection
         *-----------------------------------------------*)
        procedure setResponse(aresponse : TLnetCGIOutput);

        property response : TLnetCGIOutput read getResponse write setResponse;
    end;

implementation

uses

    Classes,
    StreamAdapterImpl;

    (*!------------------------------------------------
     * get TLHttpServer response connection
     *-----------------------------------------------
     * @return connection
     *-----------------------------------------------*)
    function TLnetStdOutWriter.getResponse() : TLnetCGIOutput;
    begin
        result := fResponse;
    end;

    (*!------------------------------------------------
     * set TLHttpServer response connection
     *-----------------------------------------------*)
    procedure TLnetStdOutWriter.setResponse(aresponse : TLnetCGIOutput);
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
        //we are not using stream parameter as this basically null implementation
        //when we set it in TLnetBufferedCgiOutput
        fResponse.writeResponse(TStreamAdapter.create(TStringStream.create(str)));
        result := self;
    end;

end.
