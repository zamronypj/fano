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
    RouteMatcherIntf;

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
    public
        constructor create(
            const routes : IRouteMatcher;
            const respFactory : IResponseFactory;
            const reqFactory : IRequestFactory
        );
        destructor destroy; override;
        function dispatchRequest(const env: ICGIEnvironment) : IResponse;
    end;

implementation

uses
    ERouteHandlerNotFoundImpl;

    constructor TDispatcher.create(
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        routeCollection := routes;
        responseFactory := respFactory;
        requestFactory := reqFactory;
    end;

    destructor TDispatcher.destroy();
    begin
        inherited destroy();
        routeCollection := nil;
        responseFactory := nil;
        requestFactory := nil;
    end;

    function TDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        response : IResponse;
        request : IRequest;
        method, uri : string;
    begin
        try
            response := responseFactory.build(env);
            request := requestFactory.build(env);

            method := env.requestMethod();
            uri := env.requestUri();
            routeHandler := routeCollection.find(method, uri);
            if (routeHandler = nil) then
            begin
                raise ERouteHandlerNotFound.create('Route not found. Method:' + method + ' Uri:'+uri);
            end;
            //TODO middlewares := buildMiddlewareList(routeHandler);
            //TODO result := middlewares.handleRequest(request, response);
            result := routeHandler.handleRequest(request, response);
        finally
            response := nil;
            request := nil;
            routeHandler := nil;
        end;
    end;
end.
