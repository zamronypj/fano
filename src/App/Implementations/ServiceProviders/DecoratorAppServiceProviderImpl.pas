{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DecoratorAppServiceProviderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DaemonAppServiceProviderIntf,
    AppServiceProviderIntf,
    DependencyContainerIntf,
    ServiceProviderIntf,
    ErrorHandlerIntf,
    DispatcherIntf,
    EnvironmentIntf,
    RunnableWithDataNotifIntf,
    StdInIntf,
    StdOutIntf,
    OutputBufferIntf,
    RouteMatcherIntf,
    RouteBuilderIntf,
    RouterIntf;

type

    {*------------------------------------------------
     * interface for any class having capability to
     * register one or more service factories
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TDecoratorAppServiceProvider = class (TInterfacedObject, IDaemonAppServiceProvider)
    protected
        fDaemonSvc : IDaemonAppServiceProvider;
    public
        constructor create(const actualSvc : IDaemonAppServiceProvider);
        destructor destroy(); override;

        function getContainer() : IDependencyContainer;

        function getErrorHandler() : IErrorHandler;

        function getDispatcher() : IDispatcher;

        function getEnvironment() : ICGIEnvironment;

        function getRouter() : IRouter;

        function getRouteBuilder() : IRouteBuilder;

        function getStdIn() : IStdIn; virtual;

        function getServer() : IRunnableWithDataNotif; virtual;

        function getProtocol() : IProtocolProcessor; virtual;

        function getOutputBuffer() : IOutputBuffer;

        function getStdOut() : IStdOut; virtual;

    end;

implementation

uses

    StdInFromStreamImpl,
    NullStreamAdapterImpl,
    NullStdOutImpl,
    NullProtocolProcessorImpl,
    NullRunnableWithDataNotifImpl,
    OutputBufferImpl;

    constructor TDecoratorAppServiceProvider.create(const actualSvc : IDaemonAppServiceProvider);
    begin
        fDaemonSvc := actualSvc;
    end;

    destructor TDecoratorAppServiceProvider.destroy();
    begin
        fDaemonSvc := nil;
        inherited destroy();
    end;

    function TDecoratorAppServiceProvider.getContainer() : IDependencyContainer;
    begin
        result := fDaemonSvc.getContainer();
    end;

    function TDecoratorAppServiceProvider.getErrorHandler() : IErrorHandler;
    begin
        result := fDaemonSvc.getErrorHandler();
    end;

    function TDecoratorAppServiceProvider.getDispatcher() : IDispatcher;
    begin
        result := fDaemonSvc.getDispatcher();
    end;

    function TDecoratorAppServiceProvider.getEnvironment() : ICGIEnvironment;
    begin
        result := fDaemonSvc.getEnvironment();
    end;

    function TDecoratorAppServiceProvider.getRouter() : IRouter;
    begin
        result := fDaemonSvc.getRouter();
    end;

    function TDecoratorAppServiceProvider.getRouteBuilder() : IRouteBuilder;
    begin
        result := fDaemonSvc.getRouteBuilder();
    end;

    function TDecoratorAppServiceProvider.getStdIn() : IStdIn;
    begin
        result := fDaemonSvc.getStdIn();
    end;

    function TDecoratorAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        result := fDaemonSvc.getServer();
    end;

    function TDecoratorAppServiceProvider.getProtocol() : IProtocolProcessor;
    begin
        result := fDaemonSvc.getProtocol();
    end;

    function TDecoratorAppServiceProvider.getOutputBuffer() : IOutputBuffer;
    begin
        result := fDaemonSvc.getOutputBuffer();
    end;

    function TDecoratorAppServiceProvider.getStdOut() : IStdOut;
    begin
        result := fDaemonSvc.getStdOut();
    end;
end.
