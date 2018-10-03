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
        ['{05A648AA-8AC1-4068-87F4-269D9A8D6C58}']
        function build(const env : IWebEnvironment) : IResponse;
    end;

implementation
end.
