{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadProtocolProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    CloseableIntf,
    ReadyListenerIntf,
    StreamIdIntf,
    ProtocolProcessorIntf;

type

    (*!-----------------------------------------------
     * null class having capability to process
     * stream from web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TThreadProtocolProcessor = class(TInterfacedObject, IProtocolProcessor)
    private
        fThreads : TProtocolThreadArray;
        function getAvailableThread() : TProtocolThread;
    public
        constructor create(threads : TProtocolThreadArray);
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


    constructor TThreadProtocolProcessor.create(threads : TProtocolThreadArray);
    begin
        fThreads := threads;
    end;

    destructor TThreadProtocolProcessor.destroy();
    begin
        fThreads:= nil;
        inherited destroy();
    end;

    function TThreadProtocolProcessor.getAvailableThread() : TProtocolThread;
    begin

    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TThreadProtocolProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    var protocolThread : TProtocolThread;
    begin
        protocolThread := getAvailableThread();
        protocolThread.stream := stream;
        protocolThread.streamCloser := streamCloser;
        protocolThread.streamId := streamId;
        protocolThread.start();
        result := true;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TThreadProtocolProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fStream;
    end;

    (*!------------------------------------------------
     * set listener to be notified when request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TThreadProtocolProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * get number of bytes of complete request based
     * on information buffer
     *-----------------------------------------------
     * @return number of bytes of complete request
     *-----------------------------------------------*)
    function TThreadProtocolProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        //intentionally return empty size
        result := 0;
    end;
end.
