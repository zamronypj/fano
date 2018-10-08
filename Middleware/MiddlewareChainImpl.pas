unit MiddlewareCollectionImpl;

interface

uses
    MiddlewareIntf,
    MiddlewareChainIntf,
    RequestHandlerIntf,
    RequestIntf,
    ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     manage one or more middlewares
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TMiddlewareChain = class(TInterfacedObject, IMiddlewareChain)
    private
        middlewareList : IMiddlewareCollection;
        currentIndex : integer;
    public
        constructor create(const middlewares : IMiddlewareCollection);
        destructor destroy(); override;

        function handleChainedRequest(
            const request : IRequest;
            const response : IResponse;
            const nextMiddleware : IRequestHandler
        ) : IResponse;
        function next() : IMiddleware;
    end;

implementation

    constructor TMiddlewareChain.create(const middlewares : IMiddlewareCollection);
    begin
        middlewareList := middlewares;
        currentIndex := 0;
    end;

    destructor TMiddlewareChain.destroy();
    begin
        inherited destroy();
        middlewareList := nil;
    end;

    function TMiddlewareChain.handleChainedRequest(
        const request : IRequest;
        const response : IResponse;
        const nextMiddleware : IRequestHandler
    ) : IResponse;
    var nextMw : IRequestHandler;
        newResponse : IResponse;
    begin
        if (nextMiddleware <> nil) then
        begin
            newResponse := nextMiddleware.handleRequest(request, response);
            result := handleChainedRequest(request, newResponse, next());
        end else
        begin
            result := response;
        end;
    end;

    function TMiddlewareChain.next() : IMiddleware;
    begin
        if (currentIndex < middlewareList.count() - 1) then
        begin
            inc(currentIndex);
            result := middlewareList.get(currentIndex);
        end else
        begin
            result := nil;
        end;
    end;

end.
