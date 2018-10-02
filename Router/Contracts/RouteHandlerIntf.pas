unit RouteHandlerIntf;

interface

uses
    MiddlewareIntf,
    RequestHandlerIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRouteHandler = interface(IRequestHandler)
        function addMiddleware(const middleware : IMiddleware) : IRouteHandler;
    end;

implementation
end.
