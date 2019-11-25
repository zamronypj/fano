{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MhdProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    CloseableIntf,
    ScgiParserIntf,
    ProtocolProcessorIntf,
    StreamIdIntf,
    ReadyListenerIntf;

type

    (*!-----------------------------------------------
     * Class which can process request from libmicrohttpd web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdProcessor = class(TInterfacedObject, IProtocolProcessor)
    private
        fParser : IScgiParser;
        fRequestReadyListener : IReadyListener;
        fStdIn : IStreamAdapter;

        procedure resetInternalVars();
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        function process(
            const stream : IStreamAdapter;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        ) : boolean;

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * set listener to be notified when request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IReadyListener) : IProtocolProcessor;

        (*!------------------------------------------------
         * get number of bytes of complete request based
         * on information buffer
         *-----------------------------------------------
         * @return number of bytes of complete request
         *-----------------------------------------------*)
        function expectedSize(const buff : IStreamAdapter) : int64;
    end;

implementation

uses

    SysUtils;

    constructor TMhdProcessor.create();
    begin
        inherited create();
        fRequestReadyListener := nil;
        fStdIn := nil;
    end;

    destructor TMhdProcessor.destroy();
    begin
        resetInternalVars();
        inherited destroy();
    end;

    procedure TMhdProcessor.resetInternalVars();
    begin
        fRequestReadyListener := nil;
        fStdIn := nil;
        fParser := nil;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TMhdProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    begin
        result := true;
        fParser.parse(stream);
        fStdIn := fParser.getStdIn();
        if assigned(fRequestReadyListener) then
        begin
            fRequestReadyListener.ready(
                stream,
                fParser.getEnv(),
                fStdIn
            );
        end;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TScgiProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TScgiProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        fRequestReadyListener := listener;
        result := self;
    end;

    (*!------------------------------------------------
     * get number of bytes of complete request based
     * on information buffer
     *-----------------------------------------------
     * @return number of bytes of complete request
     *-----------------------------------------------*)
    function TScgiProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        result := fParser.expectedSize(buff);
    end;
end.
