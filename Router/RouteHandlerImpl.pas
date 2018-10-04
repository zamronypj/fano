unit RouteHandlerImpl;

interface

uses
    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    MiddlewareCollectionAwareIntf,
    RouteHandlerIntf;

type
    {------------------------------------------------
     base class for route handler
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRouteHandler = class(TInterfacedObject, IRouteHandler, IMiddlewareCollectionAware)
    private
        middlewareList : IMiddlewareCollection;
    public
        constructor create(const middlewares : IMiddlewareCollection);
        destructor destroy(); override;
        function addMiddleware(const middleware : IMiddleware) : IRouteHandler;
        function getMiddlewareCollection() : IMiddlewareCollection;
        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse; virtual; abstract;
    end;

implementation

    constructor TRouteHandler.create(const middlewares : IMiddlewareCollection);
    begin
        middlewareList := middlewares;
    end;

    destructor TRouteHandler.destroy();
    begin
        middlewareList := nil;
    end;

    function TRouteHandler.addMiddleware(const middleware : IMiddleware) : IRouteHandler;
    begin
        middlewareList.add(middleware);
        result := self;
    end;

    function TRouteHandler.getMiddlewareCollection() : IMiddlewareCollection;
    begin
        result := middlewareList;
    end;

end.
