{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SimpleFastCGIAppImpl;

interface

{$MODE OBJFPC}

uses
    FastCGIAppImpl,
    DependencyContainerIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    FcgiProcessorIntf,
    OutputBufferIntf,
    RunnableWithDataNotifIntf,
    StdOutIntf;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     * and provide basic default for easier setup
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleFastCGIWebApplication = class(TFastCGIWebApplication)
    protected
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; override;
    public
      (*!-----------------------------------------------
       * constructor
       *------------------------------------------------
       * @param container dependency container
       * @param env CGI environment instance
       * @param errHandler error handler
       *----------------------------------------------
       * This is provided to simplify thing by providing
       * default service provider
       *-----------------------------------------------*)
      constructor create(
          const hostname : string;
          const port : word;
          const container : IDependencyContainer = nil;
          const errHandler : IErrorHandler = nil;
          const dispatcherInst : IDispatcher = nil
      );

    end;

implementation

uses

    DependencyContainerImpl,
    DependencyListImpl,
    EnvironmentImpl,
    ErrorHandlerImpl,
    RouteMatcherIntf,
    SimpleRouterFactoryImpl,
    SimpleDispatcherFactoryImpl,
    FcgiProcessorImpl,
    FcgiFrameParserImpl,
    FcgiRequestManagerImpl,
    OutputBufferImpl,
    FcgiStdOutWriterImpl,
    TcpWorkerServerImpl,
    StreamAdapterCollectionFactoryImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param container dependency container
     * @param env CGI environment instance
     * @param errHandler error handler
     *----------------------------------------------
     * This is provided to simplify thing by providing
     * default service provider
     *-----------------------------------------------*)
    constructor TSimpleFastCGIWebApplication.create(
        const hostname : string;
        const port : word;
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    var appContainer :  IDependencyContainer;
        appErr : IErrorHandler;
        appDispatcher : IDispatcher;
        appServer : IRunnableWithDataNotif;
        fcgiProc : TFcgiProcessor;
        appFcgiProcessor : IFcgiProcessor;
        appOutputBuffer : IOutputBuffer;
        appStdOutWriter : IStdOut;
    begin
        appContainer := container;
        if (appContainer = nil) then
        begin
            appContainer := TDependencyContainer.create(TDependencyList.create());
        end;

        appErr := errHandler;
        if (appErr = nil) then
        begin
            appErr := TErrorHandler.create();
        end;

        appServer := TTcpWorkerServer.create(hostname, port);

        fcgiProc := TFcgiProcessor.create(
            TFcgiFrameParser.create(),
            TFcgiRequestManager.create(TStreamAdapterCollectionFactory.create())
        );
        appFcgiProcessor := fcgiProc;
        appOutputBuffer := TOutputBuffer.create();
        appStdOutWriter := TFcgiStdOutWriter.create(fcgiProc);

        if (not appContainer.has('router')) then
        begin
            appContainer.add('router', TSimpleRouterFactory.create());
        end;

        appDispatcher := dispatcherInst;

        if (appDispatcher = nil) and (not appContainer.has('dispatcher')) then
        begin
            appContainer.add(
                'dispatcher',
                TSimpleDispatcherFactory.create(
                    appContainer.get('router') as IRouteMatcher
                )
            );
        end;

        inherited create(
            appContainer,
            appErr,
            appDispatcher,
            appServer,
            appFcgiProcessor,
            appOutputBuffer,
            appStdOutWriter
        );
    end;

    function TSimpleFastCGIWebApplication.initDispatcher(const container : IDependencyContainer) : IDispatcher;
    begin
        result := container.get('dispatcher') as IDispatcher;
    end;
end.
