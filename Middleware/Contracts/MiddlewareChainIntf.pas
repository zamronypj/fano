unit MiddlewareChainIntf;

interface

uses
   RequestHandlerIntf,
   RequestIntf,
   ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     stack several middlewares and call
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IMiddlewareChain = interface
        ['{47B9A178-4A0A-4599-AD67-C73B8E42B82A}']
        function handleChainedRequest(
            const request : IRequest;
            const response : IResponse;
            const nextMiddleware : IRequestHandler
        ) : IResponse;
        function next() : IRequestHandler;
    end;

implementation
end.
