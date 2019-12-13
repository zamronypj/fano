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
    TBasicAppServiceProvider = class abstract (TInterfacedObject, IAppServiceProvider, IRouteBuilder)
    protected
        fContainer : IDependencyContainer;
        fEnv : ICGIEnvironment;
        fErrHandler : IErrorHandler;
        fDispatcher : IDispatcher;
        fRouter : IRouter;
        fRouteMatcher : IRouteMatcher;

        function getRouteMatcher() : IRouteMatcher; virtual;

    public
        constructor create();
        destructor destroy(); override;

        function getContainer() : IDependencyContainer; virtual;

        function getErrorHandler() : IErrorHandler;  virtual;

        function getDispatcher() : IDispatcher;  virtual;

        function getEnvironment() : ICGIEnvironment; virtual;

        function getRouter() : IRouter; virtual;

        function getStdIn() : IStdIn; virtual;

        function getRouteBuilder() : IRouteBuilder; virtual;

        (*!--------------------------------------------------------
         * register all services
         *---------------------------------------------------------
         * @param container service container
         *---------------------------------------------------------
         * Descendant must implement this and registers services
         * according to their requirement
         *---------------------------------------------------------*)
        procedure register(const container : IDependencyContainer); virtual; abstract;

        (*!----------------------------------------------
         * build application routes
         * ----------------------------------------------
         * @param router instance of router
         *-----------------------------------------------*)
        procedure buildRoutes(const router : IRouter); virtual; abstract;
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
        fContainer := TDependencyContainer.create(TDependencyList.create());
        fEnv := TCGIEnvironment.create();
        fErrHandler := TErrorHandler.create();
        fDispatcher := nil;
        fRouter := nil;
        fRouteMatcher := nil;
        fStdIn := TStdInReader.create();
    end;

    destructor TBasicAppServiceProvider.destroy();
    begin
        fContainer := nil;
        fEnv := nil;
        fErrHandler := nil;
        fDispatcher := nil;
        fRouter := nil;
        fRouteMatcher := nil;
        inherited destroy();
    end;

    function TBasicAppServiceProvider.getContainer() : IDependencyContainer;
    begin
        result := fContainer;
    end;

    function TBasicAppServiceProvider.getErrorHandler() : IErrorHandler;
    begin
        result := fErrHandler;
    end;

    function TBasicAppServiceProvider.getRouteBuilder() : IRouteBuilder;
    begin
        result := self;
    end;

    function TBasicAppServiceProvider.getDispatcher() : IDispatcher;
    var dispatcherSvc : string;
    begin
        if (fDispatcher = nil) then
        begin
            dispatcherSvc := GuidToString(IDispatcher);
            if (not fContainer.has(dispatcherSvc)) then
            begin
                fContainer.add(
                    dispatcherSvc,
                    TSimpleDispatcherFactory.create(
                        getRouteMatcher(),
                        TRequestResponseFactory.create()
                    )
                );
                fDispatcher := fContainer.get(dispatcherSvc) as IDispatcher;
            end;
        end;

        if (fDispatcher = nil) then
        begin
            raise EInvalidDispatcher.create(sErrInvalidDispatcher);
        end;

        result := fDispatcher;

    end;

    function TBasicAppServiceProvider.getEnvironment() : ICGIEnvironment;
    begin
        result := fEnv;
    end;

    function TBasicAppServiceProvider.getRouter() : IRouter;
    var routerSvc : string;
    begin
        if (fRouter = nil) then
        begin
            routerSvc := GuidToString(IRouter);
            if (not fContainer.has(routerSvc)) then
            begin
                fContainer.add(routerSvc, TSimpleRouterFactory.create());
                fContainer.alias(GuidToString(IRouteMatcher), routerSvc);
            end;
            fRouter := fContainer.get(routerSvc) as IRouter;
        end;
        result := fRouter;
    end;

    function TBasicAppServiceProvider.getRouteMatcher() : IRouteMatcher;
    var routeMatcherSvc : string;
    begin
        if (fRouteMatcher = nil) then
        begin
            routeMatcherSvc := GuidToString(IRouteMatcher);
            if (not fContainer.has(routeMatcherSvc)) then
            begin
                fContainer.add(routeMatcherSvc, TSimpleRouterFactory.create());
                fContainer.alias(GuidToString(IRouter), routeMatcherSvc);
            end;
            fRouteMatcher := fContainer.get(routeMatcherSvc) as IRouteMatcher;
        end;
        result := fRouteMatcher;
    end;

    function TBasicAppServiceProvider.getStdIn() : IStdIn;
    begin
        result := fStdIn;
    end;

end.
