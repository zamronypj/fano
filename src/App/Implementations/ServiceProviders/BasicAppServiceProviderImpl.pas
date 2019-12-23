{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit BasicAppServiceProviderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    AppServiceProviderIntf,
    DependencyContainerIntf,
    ServiceProviderIntf,
    ErrorHandlerIntf,
    DispatcherIntf,
    EnvironmentIntf,
    StdInIntf,
    RouteMatcherIntf,
    RouterIntf;

type

    {*------------------------------------------------
     * interface for any class having capability to
     * register one or more service factories
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TBasicAppServiceProvider = class abstract (TInterfacedObject, IAppServiceProvider)
    protected
        fContainer : IDependencyContainer;
        fEnv : ICGIEnvironment;
        fErrHandler : IErrorHandler;
        fDispatcher : IDispatcher;
        fRouter : IRouter;
        fRouteMatcher : IRouteMatcher;
        fStdIn : IStdIn;

        function getRouteMatcher() : IRouteMatcher; virtual;

        function buildContainer() : IDependencyContainer; virtual;
        function buildErrorHandler(const ctnr : IDependencyContainer) : IErrorHandler; virtual;
        function buildEnvironment(const ctnr : IDependencyContainer) : ICGIEnvironment; virtual;
        function buildStdIn(const ctnr : IDependencyContainer) : IStdIn; virtual;
        function buildRouter(const ctnr : IDependencyContainer) : IRouter; virtual;
        function buildDispatcher(
            const ctnr : IDependencyContainer;
            const routeMatcher : IRouteMatcher
        ) : IDispatcher; virtual;
    public
        constructor create();
        destructor destroy(); override;

        function getContainer() : IDependencyContainer;

        function getErrorHandler() : IErrorHandler;

        function getDispatcher() : IDispatcher; virtual;

        function getEnvironment() : ICGIEnvironment;

        function getRouter() : IRouter; virtual;

        function getStdIn() : IStdIn;

        (*!--------------------------------------------------------
         * register all services
         *---------------------------------------------------------
         * @param cntr service container
         *---------------------------------------------------------
         * Descendant must implement this and registers services
         * according to their requirement
         *---------------------------------------------------------*)
        procedure register(const cntr : IDependencyContainer); virtual; abstract;

    end;

implementation

uses

    SysUtils,
    DependencyContainerImpl,
    DependencyListImpl,
    EnvironmentImpl,
    ErrorHandlerImpl,
    SimpleRouterFactoryImpl,
    SimpleDispatcherFactoryImpl,
    StdInReaderImpl,
    RequestResponseFactoryImpl,
    EInvalidDispatcherImpl;

resourcestring

    sErrInvalidDispatcher = 'Invalid dispatcher';

    constructor TBasicAppServiceProvider.create();
    begin
        fContainer := buildContainer();
        fEnv := buildEnvironment(fContainer);
        fErrHandler := buildErrorHandler(fContainer);
        fStdIn := buildStdIn(fContainer);
        fRouter := buildRouter(fContainer);
        fDispatcher := buildDispatcher(fContainer, getRouteMatcher());
    end;

    destructor TBasicAppServiceProvider.destroy();
    begin
        fContainer := nil;
        fEnv := nil;
        fErrHandler := nil;
        fRouter := nil;
        fRouteMatcher := nil;
        fDispatcher := nil;
        inherited destroy();
    end;

    function TBasicAppServiceProvider.buildContainer() : IDependencyContainer;
    begin
        result := TDependencyContainer.create(TDependencyList.create());
    end;

    function TBasicAppServiceProvider.buildErrorHandler(
        const ctnr : IDependencyContainer
    ) : IErrorHandler;
    begin
        result := TErrorHandler.create();
    end;

    function TBasicAppServiceProvider.buildEnvironment(
        const ctnr : IDependencyContainer
    ) : ICGIEnvironment;
    begin
        result := TCGIEnvironment.create();
    end;

    function TBasicAppServiceProvider.buildStdIn(const ctnr : IDependencyContainer) : IStdIn;
    begin
        result := TStdInReader.create();
    end;

    function TBasicAppServiceProvider.buildRouter(
        const ctnr : IDependencyContainer
    ) : IRouter;
    var routerSvc : string;
    begin
        routerSvc := GuidToString(IRouter);
        ctnr.add(routerSvc, TSimpleRouterFactory.create());
        result := ctnr.get(routerSvc) as IRouter;
        fRouteMatcher := result as IRouteMatcher;
    end;


    function TBasicAppServiceProvider.buildDispatcher(
        const ctnr : IDependencyContainer;
        const routeMatcher : IRouteMatcher
    ) : IDispatcher;
    var dispatcherSvc : string;
    begin
        dispatcherSvc := GuidToString(IDispatcher);
        ctnr.add(
            dispatcherSvc,
            TSimpleDispatcherFactory.create(
                routeMatcher,
                TRequestResponseFactory.create()
            )
        );
        result := ctnr.get(dispatcherSvc) as IDispatcher;
    end;

    function TBasicAppServiceProvider.getContainer() : IDependencyContainer;
    begin
        result := fContainer;
    end;

    function TBasicAppServiceProvider.getErrorHandler() : IErrorHandler;
    begin
        result := fErrHandler;
    end;

    function TBasicAppServiceProvider.getDispatcher() : IDispatcher;
    begin
        result := fDispatcher;
    end;

    function TBasicAppServiceProvider.getEnvironment() : ICGIEnvironment;
    begin
        result := fEnv;
    end;

    function TBasicAppServiceProvider.getRouter() : IRouter;
    begin
        result := fRouter;
    end;

    function TBasicAppServiceProvider.getRouteMatcher() : IRouteMatcher;
    begin
        result := fRouteMatcher;
    end;

    function TBasicAppServiceProvider.getStdIn() : IStdIn;
    begin
        result := fStdIn;
    end;

end.
