unit EnvironmentFactoryImpl;

interface

uses
    EnvironmentFactoryIntf,
    DependencyAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability to retrieve
     CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TWebEnvironmentFactory = class(TInterfacedObject, IWebEnvironmentFactory)
    private
    public
        function build() : IDependencyAware;
    end;

implementation

uses
    EnvironmentImpl;

    function TWebEnvironmentFactory.build() : IDependencyAware;
    begin
        result := TWebEnvironment.create();
    end;

end.
