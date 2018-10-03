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
        ['{F13A78C0-3A00-4E19-8C84-B6A7A77A3B25}']
        function dispatchRequest(const env: IWebEnvironment) : IResponse;
    end;

implementation
end.
