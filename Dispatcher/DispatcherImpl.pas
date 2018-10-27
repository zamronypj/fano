{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DispatcherImpl;

interface

{$MODE OBJFPC}

uses

    DispatcherIntf,
    DependencyIntf,
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestIntf,
    RequestFactoryIntf,
    RequestHandlerIntf,
    RouteHandlerIntf,
    RouteMatcherIntf,
    MiddlewareChainIntf,
    MiddlewareCollectionIntf,
    MiddlewareChainFactoryIntf,
    MiddlewareCollectionAwareIntf;

type

    (*!---------------------------------------------------
     * Request dispatcher class having capability dispatch
     * request and return response and with middleware support
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TDispatcher = class(TInterfacedObject, IDispatcher, IDependency)
    private
        routeCollection : IRouteMatcher;
        responseFactory : IResponseFactory;
        requestFactory : IRequestFactory;
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
        function dispatchRequest(const env: ICGIEnvironment) : IResponse;
    end;

implementation

uses
    sysutils,
    MiddlewareIntf;

    constructor TDispatcher.create(
        const appBeforeMiddlewares : IMiddlewareCollection;
        const appAfterMiddlewares : IMiddlewareCollection;
        const chainFactory : IMiddlewareChainFactory;
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        appBeforeMiddlewareList := appBeforeMiddlewares;
        appAfterMiddlewareList := appAfterMiddlewares;
        middlewareChainFactory := chainFactory;
        routeCollection := routes;
        responseFactory := respFactory;
        requestFactory := reqFactory;
    end;

    destructor TDispatcher.destroy();
    begin
        inherited destroy();
        appBeforeMiddlewareList := nil;
        appAfterMiddlewareList := nil;
        middlewareChainFactory := nil;
        routeCollection := nil;
        responseFactory := nil;
        requestFactory := nil;
    end;

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        method : string;
        uriParts : TStringArray;
        middlewareChain : IMiddlewareChain;
        routeMiddlewares : IMiddlewareCollectionAware;
    begin
        try
            method := env.requestMethod();
            //remove any query string parts
            uriParts := env.requestUri().split('?');
            routeHandler := routeCollection.match(method, uriParts[0]);
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
