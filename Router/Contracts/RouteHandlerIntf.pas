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
        ['{7F3C1F5B-4D60-441B-820F-400D76EAB1DC}']
        function addMiddleware(const middleware : IMiddleware) : IRouteHandler;
    end;

implementation
end.
