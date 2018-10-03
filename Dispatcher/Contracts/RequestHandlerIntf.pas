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
        ['{483E0FAB-E1E6-4B8C-B193-F8615E039369}']
        function handleRequest(const request : IRequest; const response : IResponse) : IResponse;
    end;

implementation
end.
