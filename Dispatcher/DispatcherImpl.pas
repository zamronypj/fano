{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
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
    RequestHandlerIntf,
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

        function executeBeforeMiddlewares(const request : IRequest; const response : IResponse; var continue : boolean) : IResponse;
        function executeAfterMiddlewares(const request : IRequest; const response : IResponse; var continue : boolean) : IResponse;
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
    MiddlewareIntf,
    ERouteHandlerNotFoundImpl,
    RequestHandlerAsMiddlewareImpl;

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
      reqAsMiddleware : IMiddleware;
    begin
        collection := appMiddlewareList.merge(objWithCollection.getMiddlewareCollection());
        reqAsMiddleware := TRequestHandlerAsMiddleware.create(routeHandler);
        collection.add(reqAsMiddleware);
        result := middlewareChainFactory.build(collection);
    end;

    function TDispatcher.executeBeforeMiddlewares(const request : IRequest; const response : IResponse; var continue : boolean) : IResponse;
    begin;
    end;

    function TDispatcher.executeAfterMiddlewares(const request : IRequest; const response : IResponse; var continue : boolean) : IResponse;
    begin;
    end;

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        response : IResponse;
        request : IRequest;
        method, uri : string;
        middlewares : IMiddlewareChain;
        i, len : integer;
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

            len := beforeMiddlewares.count;
            for i:=0 to len-1 do
            begin
                middleware := beforeMiddlewares[i];
                response := middleware.handleRequest(request, response, continue);
                if (not continue) then
                begin
                    result := response;
                    exit();
                end;
            end;

            response := routeHandler.handleRequest(request, response);

            len := afterMiddlewares.count;
            for i:=0 to len-1 do
            begin
                middleware := afterMiddlewares[i];
                response := middleware.handleRequest(request, response, continue);
                if (not continue) then
                begin
                    result := response;
                    exit();
                end;
            end;

        finally
            response := nil;
            request := nil;
            routeHandler := nil;
            middlewares := nil;
        end;
    end;
end.
