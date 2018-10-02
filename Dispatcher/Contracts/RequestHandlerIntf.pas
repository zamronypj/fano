unit RequestHandlerIntf;

interface

uses RequestIntf, ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability handle
     request and return new response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequestHandler = interface
        function handleRequest(const request : IRequest; const response : IResponse) : IResponse;
    end;

implementation
end.
