unit ResponseFactoryImpl;

interface

uses
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    DependencyContainerIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TResponseFactory = class(TInterfacedObject, IResponseFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build(const env : ICGIEnvironment) : IResponse;
    end;

implementation
uses
    ResponseImpl;

    constructor TResponseFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TResponseFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

    function TResponseFactory.build(const env : ICGIEnvironment) : IResponse;
    begin
        result := TResponse.create(env);
    end;
end.
