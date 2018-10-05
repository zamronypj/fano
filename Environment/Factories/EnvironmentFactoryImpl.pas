unit EnvironmentFactoryImpl;

interface

uses
    EnvironmentFactoryIntf,
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class to create class having capability
     to retrieve CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TCGIEnvironmentFactory = class(TFactory, ICGIEnvironmentFactory, IDependencyFactory)
    public
        function build() : IDependencyAware; override;
    end;

implementation

uses
    EnvironmentImpl;

    function TCGIEnvironmentFactory.build() : IDependencyAware;
    begin
        result := TCGIEnvironment.create();
    end;

end.
