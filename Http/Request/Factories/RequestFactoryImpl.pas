unit RequestFactoryImpl;

interface

uses
    EnvironmentIntf,
    RequestIntf,
    RequestFactoryIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build request instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRequestFactory = class(TInterfacedObject, IRequestFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build(const env : ICGIEnvironment) : IRequest;
    end;

implementation

uses
    RequestImpl;

    constructor TRequestFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TRequestFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

    function TRequestFactory.build(const env : ICGIEnvironment) : IRequest;
    begin
        result := TRequest.create(env);
    end;
end.
