unit RequestFactoryIntf;

interface

uses
    EnvironmentIntf,
    RequestIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequestFactory = interface
        function build(const env : IWebEnvironment) : IRequest;
    end;

implementation
end.
