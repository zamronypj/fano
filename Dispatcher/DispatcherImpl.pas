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
    InjectableObjectImpl;

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

    sysutils,
    RouteHandlerIntf,
    MiddlewareIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareChainIntf,
    UrlHelpersImpl;

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

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        middlewareChain : IMiddlewareChain;
        routeMiddlewares : IMiddlewareCollectionAware;
    begin
        try
            routeHandler := getRouteHandler(env);
            routeMiddlewares := routeHandler.getMiddlewares();
            middlewareChain := middlewareChainFactory.build(
                appBeforeMiddlewareList,
                appAfterMiddlewareList,
                routeMiddlewares.getBefore(),
                routeMiddlewares.getAfter()
            );
            result := middlewareChain.execute(
                requestFactory.build(env),
                responseFactory.build(env),
                routeHandler
            );
        finally
            routeHandler := nil;
            middlewareChain := nil;
            routeMiddlewares := nil;
        end;
    end;
end.
