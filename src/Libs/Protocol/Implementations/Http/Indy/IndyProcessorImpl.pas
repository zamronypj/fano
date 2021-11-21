{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit IndyProcessorImpl;

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
    //indy related units
    IdBaseComponent,
    IdComponent,
    IdTCPServer,
    IdCustomHTTPServer,
    IdContext,
    IdSchedulerOfThreadPool,
    IdHTTPServer;

type

    (*!-----------------------------------------------
     * Class which can process request using Indy
     * TIdHTTPServer web server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TIndyProcessor = class(TInterfacedObject, IProtocolProcessor, IRunnable, IRunnableWithDataNotif)
    private
        fLock : TCriticalSection;
        fStdIn : IStreamAdapter;
        fRequestReadyListener : IReadyListener;
        fDataListener : IDataAvailListener;
        fSvrConfig : THttpSvrConfig;
        fMimeLoaded : boolean;
        fConnection : IFpwebResponseAware;

        fHttpSvr : TIdHTTPServer;

        function initHttpServer(const svrConfig : THttpSvrConfig) : TIdHTTPServer;
        procedure initThreadPool(
            const aHttpSvr: TIdHTTPServer;
            const numThread : integer
        );
        procedure waitUntilTerminate();

        function buildEnv(
            const request: TIdHTTPRequestInfo;
        ): ICGIEnvironment;

        procedure handleStaticFileRequest(
            const aFileName : string;
            response: TIdHTTPResponseInfo
        );

        procedure handleNotFoundRequest(
            ctx: TIdContext;
            request: TIdHTTPRequestInfo;
            response: TIdHTTPResponseInfo
        );

        procedure handleRequest(
            ctx: TIdContext;
            request: TIdHTTPRequestInfo;
            response: TIdHTTPResponseInfo
        );

    public
        constructor create(
            const lock : TCriticalSection;
            const conn : IIndyResponseAware;
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
    IndyaramKeyValuePairImpl,
    KeyValueEnvironmentImpl,
    NullStdInImpl,
    NullStreamAdapterImpl,
    StreamAdapterImpl;

type


    (*!-----------------------------------------------
     * internal thread to run http server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpServerThread = class(TThread)
    private
        fHttpSvr : TIdHTTPServer;
    public
        constructor create(const httpSvr : TIdHTTPServer);
        procedure execute(); override;
    end;

    constructor THttpServerThread.create(const httpSvr : TIdHTTPServer);
    begin
        inherited create(false);
        fHttpSvr := httpSvr;
    end;

    procedure THttpServerThread.execute();
    begin
        try
            fHttpSvr.active := true;
        except
            on e: Exception do
            begin
                fHttpSvr.active := false;
                writeln('Exception: ', e.ClassName);
                writeln('Message: ', e.Message);
            end;
        end;
    end;

    constructor TIndyProcessor.create(
        const lock : TCriticalSection;
        const conn : IIndyResponseAware;
        const svrConfig : THttpSvrConfig
    );
    begin
        fLock := lock;
        fConnection := conn;
        fStdIn := nil;
        fRequestReadyListener := nil;
        fDataListener := nil;
        fSvrConfig := svrConfig;
        fHttpSvr := initHttpServer(fSvrConfig);
    end;

    destructor TIndyProcessor.destroy();
    begin
        fHttpSvr.free();
        fDataListener := nil;
        fRequestReadyListener := nil;
        fStdIn := nil;
        fConnection := nil;
        fLock := nil;
        inherited destroy();
    end;

    procedure TIndyProcessor.initThreadPool(
        const aHttpSvr: TIdHTTPServer;
        const numThread : integer
    );
    var
        aThreadPoolScheduler: TIdSchedulerOfThreadPool;
    begin
        aThreadPoolScheduler := TIdSchedulerOfThreadPool.Create(FHttpSvr);
        aThreadPoolScheduler.poolSize := numThread;
        FHttpSvr.scheduler := aThreadPoolScheduler;
        FHttpSvr.maxConnections := numThread;
    end;

    function TIndyProcessor.initHttpServer(const svrConfig : TFpwebSvrConfig) : TFpHttpServer;
    var aSvr : TIdHTTPServer;
        numThread : integer;
    begin
        aSvr := TIdHTTPServer.create(nil);
        aSvr.Port := fSvrConfig.port;
        //aSvr.address := fSvrConfig.host;
        aSvr.onCommandGet := @handleRequest;
        aSvr.onCommandOther := @handleRequest;

        if (fSvrConfig.threaded) then
        begin
            numThread := fSvrConfig.threadPoolSize;
            if (numThread = 0) then
            begin
                numThread := getCpuCount();
            end;
            initThreadPool(aSvr, numThread);
        end;

        fMimeLoaded := false;
        if fileExists(fSvrConfig.MimeTypesFile) then
        begin
            MimeTypes.LoadFromFile(fSvrConfig.MimeTypesFile);
            fMimeLoaded := true;
        end;
        result := aSvr;
    end;

    procedure TIndyProcessor.handleStaticFileRequest(
        const aFileName : string;
        AResponseInfo: TIdHTTPResponseInfo
    );
    var fStream : TStream;
    begin
        fStream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
        try
            if fMimeLoaded then
            begin
                response.ContentType := MimeTypes.GetMimeType(extractFileExt(aFileName));
            end else
            begin
                response.ContentType := 'application/octet-stream';
            end;
            response.ContentLength := fstream.size;
            response.ContentStream := fStream;
            response.SendContent;
            response.ContentStream := nil;
        finally
            fStream.Free;
        end;
    end;

    function TIndyProcessor.buildEnv(
        const request: TIdHTTPRequestInfo;
    ): ICGIEnvironment;
    var
        indyData : TIndyData;
    begin
        indyData.request := request;
        indyData.serverConfig := fSvrConfig;
        result := TKeyValueEnvironment.create(
            TFpwebParamKeyValuePair.create(indyData)
        );
    end;

    procedure TIndyProcessor.handleNotFoundRequest(
        ctx: TIdContext;
        request: TIdHTTPRequestInfo;
        response: TIdHTTPResponseInfo
    );
    var aEnv : ICGIEnvironment;
    begin
        fConnection.response := response;
        if (fSvrConfig.threaded) then
        begin
            fLock.acquire();
            try
                aEnv := buildEnv(request);
                fRequestReadyListener.ready(
                    //we will not use socket stream as we will have our own IStdOut
                    //that write output with TFpHttpServer
                    TNullStreamAdapter.create(),
                    aEnv,
                    TStreamAdapter.create(TStringStream.create(request.content))
                );
            finally
                fLock.release();
            end;
        end else
        begin
            aEnv := buildEnv(request);
            fRequestReadyListener.ready(
                //we will not use socket stream as we will have our own IStdOut
                //that write output with TFpHttpServer
                TNullStreamAdapter.create(),
                aEnv,
                TStreamAdapter.create(TStringStream.create(request.content))
            );
        end;
    end;

    procedure TIndyProcessor.handleRequest(
        ctx: TIdContext;
        request: TIdHTTPRequestInfo;
        response: TIdHTTPResponseInfo
    );
    var isStaticFileRequest : boolean;
        fname : string;
        method : string;
        url : string;
    begin
        url := request.url;
        method := request.method;

        if (length(url) > 0) and (url[1] = '/') then
        begin
           delete(url, 1, 1);
        end;

        DoDirSeparators(url);
        fname := fSvrConfig.documentRoot + url;
        isStaticFileRequest := ((method = 'GET') or (method = 'HEAD')) and
            fileExists(fname);

        if isStaticFileRequest then
        begin
            handleStaticFileRequest(fname, response);
        end else
        begin
            handleNotFoundRequest(ctx, request, response);
        end;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    function TIndyProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : boolean;
    begin
        //intentationally does nothing, because TFPHttpServer
        //already does stream parsing so this is not relevant
        result := true;
    end;

    (*!------------------------------------------------
        * get StdIn stream for complete request
        *-----------------------------------------------*)
    function TIndyProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fStdIn;
    end;

    (*!------------------------------------------------
     * set listener to be notified when request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TIndyProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
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
    function TIndyProcessor.expectedSize(const buff : IStreamAdapter) : int64;
    begin
        //not relevant as TFPHttpServer does all protocol data parsing
        result := 0;
    end;

    procedure TIndyProcessor.waitUntilTerminate();
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
     * send fake connection to our own server
     *-------------------------------------------------
     * Note this is workaround
     * due to current behavior (bug?) of TInetServer
     * which does not immediately exit accept loop when
     * Active:=false until new request comes
     * workaround send fake connection just to break accept loop
     *-------------------------------------------------*)
    procedure TIndyProcessor.fakeConnect();
    begin
        try
            //TFpHttpServer always use TInetServer not unix domain socket
            //so use of TInetSocket is ok here
            TInetSocket.create(fSvrConfig.host, fSvrConfig.port).free();
        except
            //intentionally surpress all exception it may raise
        end;
    end;

    (*!------------------------------------------------
     * run it
     *-------------------------------------------------
     * @return current instance
     *-------------------------------------------------*)
    function TIndyProcessor.run() : IRunnable;
    var svrThread : THttpServerThread;
    begin
        result := self;
        svrThread := THttpServerThread.create(fHttpSvr);
        try
            //wait until we receive termination signal
            waitUntilTerminate();
            fHttpSvr.active := false;

            //create fake a new connection to allow breaking accept loop
            //thus THttpServerThread can terminate
            fakeConnect();
            svrThread.waitFor();

        finally
           svrThread.free();
        end;
    end;

    (*!------------------------------------------------
    * set instance of class that will be notified when
    * data is available
    *-----------------------------------------------
    * @param dataListener, class that wish to be notified
    * @return true current instance
    *-----------------------------------------------*)
    function TIndyProcessor.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
        result := self;
    end;

end.
