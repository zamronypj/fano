unit EnvironmentFactoryImpl;

interface

uses
    EnvironmentFactoryIntf,
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability to retrieve
     CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TWebEnvironmentFactory = class(TInterfacedObject, IWebEnvironmentFactory, IDependencyFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware;
    end;

implementation

uses
    EnvironmentImpl;

    constructor TWebEnvironmentFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TWebEnvironmentFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

    function TWebEnvironmentFactory.build() : IDependencyAware;
    begin
        result := TWebEnvironment.create();
    end;

end.
