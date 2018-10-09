unit ResponseFactoryImpl;

interface

uses
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TResponseFactory = class(TInterfacedObject, IResponseFactory)
    public
        function build(const env : ICGIEnvironment) : IResponse;
    end;

implementation
uses
    ResponseImpl;

    function TResponseFactory.build(const env : ICGIEnvironment) : IResponse;
    begin
        result := TResponse.create(env);
    end;
end.
