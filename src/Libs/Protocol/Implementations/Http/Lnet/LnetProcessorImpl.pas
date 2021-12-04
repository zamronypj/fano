{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SyncObjs,
    RunnableIntf,
    RunnableWithDataNotifIntf,
    ProtocolProcessorIntf,
    ReadyListenerIntf,
    DataAvailListenerIntf,
    EnvironmentIntf,
    CloseableIntf,
    StreamIdIntf,
    StreamAdapterIntf,
    lnet,
    lhttp,
    lwebserver,
    LnetResponseAwareIntf,
    HttpSvrConfigTypes;

type

    (*!-----------------------------------------------
     * Class which can process request from LNet
     * TLHTTPServer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLnetProcessor = class(TInterfacedObject, IProtocolProcessor, IRunnable, IRunnableWithDataNotif)
    private
        fQuit : boolean;
        fLock : TCriticalSection;
        fStdIn : IStreamAdapter;
        fRequestReadyListener : IReadyListener;
        fDataListener : IDataAvailListener;
        fSvrConfig : THttpSvrConfig;
        fMimeLoaded : boolean;
        fConnection : IFpwebResponseAware;

        fHttpSvr : TLHTTPServer;
        fFileHandler : TFileHandler;
        fFanoHandler : TLnetFanoHandler;
        fFormHandler : TFormHandler;

        fTerminateHandle : TLHandle;

        function initHttpServer(const svrConfig : THttpSvrConfig) : TLHTTPServer;
        procedure onReadTermination(aHandle: TLHandle);
    public
        constructor create(
            const lock : TCriticalSection;
            const conn : ILnetResponseAware;
            const svrConfig : THttpSvrConfig
        );
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

        (*!------------------------------------------------
         * run it
         *-------------------------------------------------
         * @return current instance
         *-------------------------------------------------*)
        function run() : IRunnable;

        (*!------------------------------------------------
        * set instance of class that will be notified when
        * data is available
        *-----------------------------------------------
        * @param dataListener, class that wish to be notified
        * @return true current instance
        *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    end;

implementation

uses

    Classes,
    SysUtils,
    ssockets,
    BaseUnix,
    SigTermImpl,
    fpmimetypes,
    FpwebParamKeyValuePairImpl,
    KeyValueEnvironmentImpl,
    NullStdInImpl,
    NullStreamAdapterImpl,
    StreamAdapterImpl;

    constructor TLnetProcessor.create(
        const lock : TCriticalSection;
        const svrConfig : THttpSvrConfig
    );
    begin
        fQuit := false;
        fLock := lock;
        fConnection := conn;
        fStdIn := nil;
        fRequestReadyListener := nil;
        fDataListener := nil;
        fSvrConfig := svrConfig;

        fHttpSvr := initHttpServer(fSvrConfig);

        //get notified when SIGTERM is received so we can
        //quit gracefully
        fTerminateHandle := TLHandle.create();
        fTerminateHandle.handle := TSigTerm.terminatePipeIn;
        fTerminateHandle.ignoreWrite := true;
        fTerminateHandle.onRead := @onReadTermination;
        fHttpSvr.Eventer.addHandle(fTerminateHandle);
    end;

    destructor TLnetProcessor.destroy();
    begin
        fHttpSvr.free();
        fFileHandler.free();
        fFormHandler.free();
        fFanoHandler.free();
        fTerminateHandle.free();
        fDataListener := nil;
        fRequestReadyListener := nil;
        fStdIn := nil;
        fConnection := nil;
        fLock := nil;
        inherited destroy();
    end;

    procedure TLnetProcessor.onReadTermination(aHandle: TLHandle);
    begin
        fQuit := true;
    end;

    function TLnetProcessor.initHttpServer(const svrConfig : TFpwebSvrConfig) : TLHTTPServer;
    var aSvr : TLHttpServer;
    begin
        aSvr := TLHttpServer.create(nil);

        aSvr.registerHandler := @handleRequest;

        //create handler for static file
        fFileHandler := TFileHandler.create();
        fFileHandler.DocumentRoot := fSvrConfig.documentRoot;
        if fileExists(fSvrConfig.MimeTypesFile) then
        begin
            fFileHandler.MimeTypeFile := fSvrConfig.MimeTypesFile;
        end;

        //create handler for multipart formdata
        fFormHandler := TFormHandler.create();

        //create handler for our app
        fFanoHandler := TLnetFanoHandler.create();
        fFanoHandler.readyListener := fRequestReadyListener;

        aSvr.registerHandler(fFileHandler);
        aSvr.registerHandler(fFormHandler);
        aSvr.registerHandler(fFanoHandler);

        result := aSvr;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TLnetProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    begin
        //intentationally does nothing, because TLHttpServer
        //already does stream parsing so this is not relevant
        result := true;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TLnetProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * set listener to be notified when request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TLnetProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
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
    function TLnetProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        //not relevant as TLHttpServer does all protocol data parsing
        result := 0;
    end;

    (*!------------------------------------------------
     * run it
     *-------------------------------------------------
     * @return current instance
     *-------------------------------------------------*)
    function TLnetProcessor.run() : IRunnable;
    begin
        result := self;
        if fHttpSvr.listen(fSvrConfig.port) then
        begin
            while not fQuit do
            begin
                fHttpSvr.callAction();
            end
        end;
    end;

    (*!------------------------------------------------
    * set instance of class that will be notified when
    * data is available
    *-----------------------------------------------
    * @param dataListener, class that wish to be notified
    * @return true current instance
    *-----------------------------------------------*)
    function TLnetProcessor.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
        result := self;
    end;

end.
