unit DispatcherIntf;

interface

uses
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestIntf,
    RequestFactoryIntf,
    RouteHandlerIntf,
    RouteFinderIntf;

type
    {------------------------------------------------
     interface for any class having capability dispatch
     request and return response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcher = class(TInterfacedObject, IDispatcher)
    private
        routeCollection : IRouteFinder;
        responseFactory : IResponseFactory;
        requestFactory : IRequestFactory;
    public
        constructor create(
            const routes : IRouteFinder;
            const respFactory : IResponseFactory;
            const reqFactory : IRequestFactory
        );
        destructor destroy; override;
        function dispatchRequest(const env: IWebEnvironment) : IResponse;
    end;

implementation

    constructor TDispatcher.create(
        const routes : IRouteFinder;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        routeCollection := routes;
        responseFactory := respFactory;
        requestFactory := reqFactory;
    end;

    destructor TDispatcher.destroy(); override;
    begin
        routeCollection := nil;
        responseFactory := nil;
        requestFactory := nil;
    end;

    function TDispatcher.dispatchRequest(const env: IWebEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        response : IResponse;
        request : IRequest;
    begin
        response := responseFactory.build(env);
        request := requestFactory.build(env);
        routeHandler := routeCollection.find(env.requestMethod(), env.requestUri());
        result := routeHandler.handleRequest(request, response);
    end;
end.
