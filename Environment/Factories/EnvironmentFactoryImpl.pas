unit EnvironmentFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class to create class having capability
     to retrieve CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TCGIEnvironmentFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    EnvironmentImpl;

    function TCGIEnvironmentFactory.build() : IDependency;
    begin
        result := TCGIEnvironment.create();
    end;

end.
