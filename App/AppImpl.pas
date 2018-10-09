{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit AppImpl;

interface

uses
   RunnableIntf,
   DependencyContainerIntf,
   AppIntf,
   ConfigIntf,
   DispatcherIntf,
   EnvironmentIntf,
   RouteCollectionIntf,
   RouteHandlerIntf,
   MiddlewareCollectionAwareIntf,
   ErrorHandlerIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        config : IAppConfiguration;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        routeCollection :IRouteCollection;
        middlewareList : IMiddlewareCollectionAware;
        errorHandler : IErrorHandler;

        function execute() : IRunnable;
    public
        constructor create(
            const cfg : IAppConfiguration;
            const dispatcherInst : IDispatcher;
            const env : ICGIEnvironment;
            const routesInst : IRouteCollection;
            const middlewares : IMiddlewareCollectionAware;
            const errorHandlerInst : IErrorHandler
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses
    sysutils,
    ResponseIntf,
    ERouteHandlerNotFoundImpl,
    EDependencyNotFoundImpl;

    constructor TFanoWebApplication.create(
        const cfg : IAppConfiguration;
        const dispatcherInst : IDispatcher;
        const env : ICGIEnvironment;
        const routesInst : IRouteCollection;
        const middlewares : IMiddlewareCollectionAware;
        const errorHandlerInst : IErrorHandler
    );
    begin
        config := cfg;
        dispatcher := dispatcherInst;
        environment := env;
        routeCollection := routesInst;
        middlewareList := middlewares;
        errorHandler := errorHandlerInst;
    end;

    destructor TFanoWebApplication.destroy();
    begin
        inherited destroy();
        config := nil;
        dispatcher := nil;
        environment := nil;
        routeCollection := nil;
        middlewareList := nil;
        errorHandler := nil;
    end;

    function TFanoWebApplication.execute() : IRunnable;
    var response : IResponse;
    begin
        try
            response := dispatcher.dispatchRequest(environment);
            response.write();
            result := self;
        finally
            response := nil;
        end;
    end;

    function TFanoWebApplication.run() : IRunnable;
    begin
        try
            result := execute();
        except
            on e : ERouteHandlerNotFound do
            begin
                errorHandler.handleError(e);
            end;

            on e : EDependencyNotFound do
            begin
                errorHandler.handleError(e);
            end;

            on e : Exception do
            begin
                errorHandler.handleError(e);
            end;
        end;
    end;
end.
