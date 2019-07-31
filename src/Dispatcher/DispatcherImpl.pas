{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DispatcherImpl;

interface

{$MODE OBJFPC}

uses

    DispatcherIntf,
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestFactoryIntf,
    RouteMatcherIntf,
    MiddlewareCollectionIntf,
    MiddlewareChainFactoryIntf,
    InjectableObjectImpl,
    BaseDispatcherImpl;

type

    (*!---------------------------------------------------
     * Request dispatcher class having capability dispatch
     * request and return response and with middleware support
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TDispatcher = class(TBaseDispatcher)
    private
        appBeforeMiddlewareList : IMiddlewareCollection;
        appAfterMiddlewareList : IMiddlewareCollection;
        middlewareChainFactory : IMiddlewareChainFactory;

        function executeMiddlewareChain(
            const env: ICGIEnvironment;
            const routeHandler : IRouteHandler;
            const routeMiddlewares : IMiddlewareCollectionAware
        ) : IResponse;

        function executeMiddlewares(
            const env: ICGIEnvironment;
            const routeHandler : IRouteHandler
        ) : IResponse;
    public
        constructor create(
            const appBeforeMiddlewares : IMiddlewareCollection;
            const appAfterMiddlewares : IMiddlewareCollection;
            const chainFactory : IMiddlewareChainFactory;
            const routes : IRouteMatcher;
            const respFactory : IResponseFactory;
            const reqFactory : IRequestFactory
        );
        destructor destroy(); override;
        function dispatchRequest(const env: ICGIEnvironment) : IResponse; override;
    end;

implementation

uses

    RouteHandlerIntf,
    MiddlewareIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareChainIntf;

    constructor TDispatcher.create(
        const appBeforeMiddlewares : IMiddlewareCollection;
        const appAfterMiddlewares : IMiddlewareCollection;
        const chainFactory : IMiddlewareChainFactory;
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        inherited create(routes, respFactory, reqFactory);
        appBeforeMiddlewareList := appBeforeMiddlewares;
        appAfterMiddlewareList := appAfterMiddlewares;
        middlewareChainFactory := chainFactory;
    end;

    destructor TDispatcher.destroy();
    begin
        inherited destroy();
        appBeforeMiddlewareList := nil;
        appAfterMiddlewareList := nil;
        middlewareChainFactory := nil;
    end;

    function TDispatcher.executeMiddlewareChain(
        const env: ICGIEnvironment;
        const routeHandler : IRouteHandler;
        const routeMiddlewares : IMiddlewareCollectionAware
    ) : IResponse;
    var middlewareChain : IMiddlewareChain;
    begin
        middlewareChain := middlewareChainFactory.build(
            appBeforeMiddlewareList,
            appAfterMiddlewareList,
            routeMiddlewares.getBefore(),
            routeMiddlewares.getAfter()
        );
        try
            result := middlewareChain.execute(
                requestFactory.build(env),
                responseFactory.build(env),
                routeHandler
            );
        finally
            middlewareChain := nil;
        end;
    end;

    function TDispatcher.executeMiddlewares(
        const env: ICGIEnvironment;
        const routeHandler : IRouteHandler
    ) : IResponse;
    var routeMiddlewares : IMiddlewareCollectionAware;
    begin
        routeMiddlewares := routeHandler.getMiddlewares();
        try
            result := executeMiddlewareChain(env, routeHandler, routeMiddlewares);
        finally
            routeMiddlewares := nil;
        end;
    end;

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
    begin
        routeHandler := getRouteHandler(env);
        try
            result := executeMiddlewares(env, routeHandler);
        finally
            routeHandler := nil;
        end;
    end;
end.
