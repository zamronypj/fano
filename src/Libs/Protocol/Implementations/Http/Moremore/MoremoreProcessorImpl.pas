{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MoremoreProcessorImpl;

interface

{$MODE DELPHI}
{$H+}

{$I mormot.defines.inc}

uses
    {$I mormot.uses.inc}
    mormot.core.base,
    mormot.core.os,
    mormot.core.text,
    mormot.net.http,
    mormot.net.server,
    mormot.net.async,

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
    MoremoreResponseAwareIntf,
    HttpSvrConfigTypes;

type

    (*!-----------------------------------------------
     * Class which can process request from Free Pascal
     * built-in web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMoremoreProcessor = class(TInterfacedObject, IProtocolProcessor, IRunnable, IRunnableWithDataNotif)
    private
        fLock : TCriticalSection;
        fRequestReadyListener : IReadyListener;
        fConnection: IMoremoreResponseAware;
        fDataListener : IDataAvailListener;
        fSvrConfig : THttpSvrConfig;
        fMimeLoaded : boolean;

        function initHttpServer(const svrConfig : THttpSvrConfig) : THttpServerSocketGeneric;
        procedure waitUntilTerminate();

        function buildEnv(
            const svrConfig : THttpSvrConfig;
            const ctxt : THttpServerRequestAbstract
        ): ICGIEnvironment;

        function handleStaticFileRequest(
            const aFileName : string;
            ctxt: THttpServerRequestAbstract
        ) : cardinal;

        function handleNotFoundRequest(Ctxt: THttpServerRequestAbstract) : cardinal;

        function handleRequest(Ctxt: THttpServerRequestAbstract) : cardinal;

    public
        constructor create(
            const lock : TCriticalSection;
            const svrConfig : THttpSvrConfig;
            const conn : IMoremoreResponseAware
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
    MoremoreKeyValuePairImpl,
    KeyValueEnvironmentImpl,
    NullStdInImpl,
    StdInFromStreamImpl,
    NullStreamAdapterImpl,
    StreamAdapterImpl;


    constructor TMoremoreProcessor.create(
        const lock : TCriticalSection;
        const svrConfig : THttpSvrConfig;
        const conn : IMoremoreResponseAware
    );
    begin
        fLock := lock;
        fRequestReadyListener := nil;
        fConnection := conn;
        fDataListener := nil;
        fSvrConfig := svrConfig;
    end;

    destructor TMoremoreProcessor.destroy();
    begin
        fDataListener := nil;
        fRequestReadyListener := nil;
        fConnection := nil;
        fLock := nil;
        inherited destroy();
    end;

    function TMoremoreProcessor.initHttpServer(const svrConfig : THttpSvrConfig) : THttpServerSocketGeneric;
    var aSvr : THttpServerSocketGeneric;
        svrPort : RawUTF8;
        opts : THttpServerOptions;
    begin
        svrPort := intToStr(fSvrConfig.port);
        opts := [
            // store all headers
            hsoHeadersUnfiltered,
            // no X-Powered-By
            hsoNoXPoweredHeader,
            hsoNoStats,
            hsoHeadersInterning,
            hsoThreadSmooting
        ];

        if fSvrConfig.useTLS then
        begin
            opts := opts + [hsoEnableTls];
        end;

        aSvr := THttpAsyncServer.Create(
            svrPort,

            //not using onstart/onstop event
            nil,
            nil,

            // process name
            fSvrConfig.serverName,

            // thread pool count
            fSvrConfig.threadPoolSize,

            // keep alive timeout
            fSvrConfig.timeout,

            opts
        );

        // TODO: move to server config
        aSvr.HttpQueueLength := 100000;
        aSvr.onRequest := handleRequest;

        fMimeLoaded := false;
        if fileExists(fSvrConfig.MimeTypesFile) then
        begin
            MimeTypes.LoadFromFile(fSvrConfig.MimeTypesFile);
            fMimeLoaded := true;
        end;
        result := aSvr;
    end;

    // quick check for case-sensitive 'HEAD' HTTP method name
    function IsHead(const method: RawUtf8): boolean; inline;
    begin
       result := PCardinal(method)^ = ord('H') + ord('E') shl 8 + ord('A') shl 16 +  ord('D') shl 24;
    end;

    function TMoremoreProcessor.handleRequest(ctxt: THttpServerRequestAbstract) : cardinal;
    var isStaticFileRequest : boolean;
        fname : string;
        url : string;
    begin
        url := ctxt.url;

        if (length(url) > 0) and (url[1] = '/') then
        begin
           delete(url, 1, 1);
        end;

        DoDirSeparators(url);
        fname := fSvrConfig.documentRoot + url;
        isStaticFileRequest := (isGet(ctxt.method) or isHead(ctxt.method)) and
            fileExists(fname) and (not directoryExists(fname));

        if isStaticFileRequest then
        begin
            result := handleStaticFileRequest(fname, ctxt);
        end else
        begin
            result := handleNotFoundRequest(ctxt);
        end;
    end;

    function TMoremoreProcessor.handleStaticFileRequest(
        const aFileName : string;
        ctxt: THttpServerRequestAbstract
    ) : cardinal;
    begin
        ctxt.OutContentType := STATICFILE_CONTENT_TYPE;
        ctxt.OutContent := aFileName;
        result := HTTP_SUCCESS;
    end;

    function TMoremoreProcessor.buildEnv(
        const svrConfig : THttpSvrConfig;
        const ctxt : THttpServerRequestAbstract
    ): ICGIEnvironment;
    var webData : TMoremoreData;
    begin
        webData.ctxt := ctxt;
        webData.serverConfig := svrConfig;
        result := TKeyValueEnvironment.create(
            TMoremoreKeyValuePair.create(webData)
        );
    end;

    function TMoremoreProcessor.handleNotFoundRequest(
        ctxt: THttpServerRequestAbstract
    ) : cardinal;
    var webEnv : ICGIEnvironment;
        sockStr, body : IStreamAdapter;
    begin
        fConnection.response := ctxt;

        webEnv := buildEnv(fSvrConfig, ctxt);
        //we will not use socket stream as we will have our own IStdOut
        //that write output with THttpServerGeneric
        sockStr := TNullStreamAdapter.create();
        body := TStreamAdapter.create(TStringStream.create(ctxt.InContent));

        fLock.acquire();
        try
            fRequestReadyListener.ready(sockStr, webEnv, body);
        finally
            fLock.release();
        end;
        result := HTTP_SUCCESS;
    end;


    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TMoremoreProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    begin
        //intentationally does nothing, because THttpServerGeneric
        //already does stream parsing so this is not relevant
        result := true;
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TMoremoreProcessor.getStdIn() : IStreamAdapter;
    begin
        // not used as THttpServerGeneric does stream parsing
        // so just return null implementation
        result := TNullStreamAdapter.create();
    end;

    (*!------------------------------------------------
     * set listener to be notified when request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TMoremoreProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        fLock.acquire();
        try
            fRequestReadyListener := listener;
        finally
            fLock.release();
        end;
        result := self;
    end;

    (*!------------------------------------------------
     * get number of bytes of complete request based
     * on information buffer
     *-----------------------------------------------
     * @return number of bytes of complete request
     *-----------------------------------------------*)
    function TMoremoreProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        //not relevant as THttpServerGeneric does all protocol data parsing
        result := 0;
    end;

    procedure TMoremoreProcessor.waitUntilTerminate();
    var fds : TFDSet;
    begin
        fds := default(TFDSet);
        fpfd_zero(fds);
        //terminatePipeIn will be ready for IO when application is terminated
        //see SigTermImpl unit
        fpfd_set(TSigTerm.terminatePipeIn, FDS);
        //wait forever until terminatePipeIn changes
        fpSelect(TSigTerm.terminatePipeIn + 1, @fds, nil, nil, nil);
    end;

    (*!------------------------------------------------
     * run it
     *-------------------------------------------------
     * @return current instance
     *-------------------------------------------------*)
    function TMoremoreProcessor.run() : IRunnable;
    var aSvr: THttpServerSocketGeneric;
    begin
        aSvr := initHttpServer(fSvrConfig);
        try
           result := self;
           aSvr.WaitStarted();
           //wait until we receive termination signal
           waitUntilTerminate();
        finally
           aSvr.free();
        end;
    end;

    (*!------------------------------------------------
    * set instance of class that will be notified when
    * data is available
    *-----------------------------------------------
    * @param dataListener, class that wish to be notified
    * @return true current instance
    *-----------------------------------------------*)
    function TMoremoreProcessor.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
        result := self;
    end;

end.
