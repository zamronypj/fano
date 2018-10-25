unit RequestFactoryImpl;

interface

uses
    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRequestFactory = class(TInterfacedObject, IRequestFactory)
    public
        function build(const env : ICGIEnvironment) : IRequest;
    end;

implementation

uses
    RequestImpl,
    HashListImpl;

    function TRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    begin
        result := TRequest.create(env, THashList.create(), THashList.create());
    end;
end.
