{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (Apache License 2.0)
 *}
unit DispatcherImpl;

interface

uses
    DispatcherIntf,
    DependencyIntf,
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestIntf,
    RequestFactoryIntf,
    RouteHandlerIntf,
    RouteMatcherIntf,
    MiddlewareChainIntf,
    MiddlewareCollectionIntf,
    MiddlewareChainFactoryIntf,
    MiddlewareCollectionAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability dispatch
     request and return response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcher = class(TInterfacedObject, IDispatcher, IDependency)
    private
        routeCollection : IRouteMatcher;
        responseFactory : IResponseFactory;
        requestFactory : IRequestFactory;
        appMiddlewareList : IMiddlewareCollection;
        middlewareChainFactory : IMiddlewareChainFactory;


        function buildMiddlewareChain(
              const routeHandler : IRequestHandler;
              const objWithCollection : IMiddlewareCollectionAware
        ) : IMiddlewareChain;
    public
        constructor create(
            const appMiddlewares : IMiddlewareCollection;
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
    ERouteHandlerNotFoundImpl;

    constructor TDispatcher.create(
        const appMiddlewares : IMiddlewareCollection;
        const chainFactory : IMiddlewareChainFactory;
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        appMiddlewareList := appMiddlewares;
        middlewareChainFactory := chainFactory;
        routeCollection := routes;
        responseFactory := respFactory;
        requestFactory := reqFactory;
    end;

    destructor TDispatcher.destroy();
    begin
        inherited destroy();
        appMiddlewareList := nil;
        middlewareChainFactory := nil;
        routeCollection := nil;
        responseFactory := nil;
        requestFactory := nil;
    end;

    function TDispatcher.buildMiddlewareChain(
          const routeHandler : IRequestHandler;
          const objWithCollection : IMiddlewareCollectionAware
    ) : IMiddlewareChain;
    var collection : IMiddlewareCollection;
    begin
        collection := appMiddlewareList.merge(objWithCollection.getMiddlewareCollection());
        collection.add(routeHandler);
        result := middlewareChainFactory.build(collection);
    end;

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        response : IResponse;
        request : IRequest;
        method, uri : string;
        middlewares : IMiddlewareChain;
    begin
        try
            method := env.requestMethod();
            uri := env.requestUri();
            routeHandler := routeCollection.find(method, uri);
            if (routeHandler = nil) then
            begin
                raise ERouteHandlerNotFound.create('Route not found. Method:' + method + ' Uri:'+uri);
            end;
            response := responseFactory.build(env);
            request := requestFactory.build(env);
            middlewares := buildMiddlewareChain(
                routeHandler,
                routeHandler as IMiddlewareCollectionAware
            );
            result := middlewares.handleChainedRequest(request, response, middlewares.next());
        finally
            response := nil;
            request := nil;
            routeHandler := nil;
            middlewares := nil;
        end;
    end;
end.
