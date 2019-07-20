{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    CloseableIntf,
    ScgiParserIntf,
    ProtocolProcessorIntf,
    ReadyListenerIntf;

type

    (*!-----------------------------------------------
     * Class which can process SCGI stream from web server
     *
     * @link https://python.ca/scgi/protocol.txt
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TScgiProcessor = class(TInterfacedObject, IProtocolProcessor)
    private
        fParser : IScgiParser;
        fRequestReadyListener : IRequestReadyListener;
        fStdIn : IStreamAdapter;
    public
        constructor create(const aParser : IScgiParser);
        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure process(const stream : IStreamAdapter; const streamCloser : ICloseable);

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
    end;

implementation

    constructor TScgiProcessor.create(const aParser : IScgiParser);
    begin
        inherited create();
        fParser := aParser;
        fRequestReadyListener := nil;
        fStdIn := nil;
    end;

    destructor TScgiProcessor.destroy();
    begin
        inherited destroy();
        fRequestReadyListener := nil;
        fStdIn := nil;
        fParser := nil;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    procedure TScgiProcessor.process(const stream : IStreamAdapter; const streamCloser : ICloseable);
    var handled : boolean;
    begin
        if (fParser.parse(stream)) then
        begin
            fStdIn := fParser.getStdIn();
            if assigned(fRequestReadyListener) then
            begin
                handled := fRequestReadyListener.ready(
                        stream,
                        fParser.getEnv(),
                        fStdIn
                );
                if handled then
                begin
                    streamCloser.close();
                end;
            end;
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

end.
