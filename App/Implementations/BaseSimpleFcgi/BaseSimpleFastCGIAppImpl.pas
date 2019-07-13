{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit BaseSimpleFastCGIAppImpl;

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
     * and provide basic default for easier setup for FastCGI
     * web application
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBaseSimpleFastCGIWebApplication = class(TFastCGIWebApplication)
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
            const workerServer : IRunnableWithDataNotif;
            const container : IDependencyContainer = nil;
            const errHandler : IErrorHandler = nil;
            const dispatcherInst : IDispatcher = nil
        );

    end;

implementation

uses

    FcgiFrameParserFactoryIntf,
    FcgiFrameParserFactoryImpl,
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
    constructor TBaseSimpleFastCGIWebApplication.create(
        const workerServer : IRunnableWithDataNotif;
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    var appContainer :  IDependencyContainer;
        appErr : IErrorHandler;
        appDispatcher : IDispatcher;
        fcgiProc : TFcgiProcessor;
        appFcgiProcessor : IFcgiProcessor;
        appOutputBuffer : IOutputBuffer;
        appStdOutWriter : IStdOut;
        aParserFactory : IFcgiFrameParserFactory;
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

        aParserFactory := TFcgiFrameParserFactory.create();
        fcgiProc := TFcgiProcessor.create(
            aParserFactory.build(),
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
            workerServer,
            appFcgiProcessor,
            appOutputBuffer,
            appStdOutWriter
        );
    end;

    function TBaseSimpleFastCGIWebApplication.initDispatcher(const container : IDependencyContainer) : IDispatcher;
    begin
        result := container.get('dispatcher') as IDispatcher;
    end;
end.
