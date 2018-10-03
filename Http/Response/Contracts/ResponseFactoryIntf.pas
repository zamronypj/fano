unit ResponseFactoryIntf;

interface

uses
    EnvironmentIntf,
    ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build response instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IResponseFactory = interface
        function build(const env : IWebEnvironment) : IResponse;
    end;

implementation
end.
