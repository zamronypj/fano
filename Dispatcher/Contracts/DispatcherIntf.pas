unit DispatcherIntf;

interface

uses EnvironmentIntf, ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability dispatch
     request and return response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDispatcher = interface
        function handleRequest(const env: IWebEnvironment) : IResponse;
    end;

implementation
end.
