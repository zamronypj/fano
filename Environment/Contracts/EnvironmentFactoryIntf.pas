unit EnvironmentFactoryIntf;

interface

uses
    DependencyAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build web environment instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebEnvironmentFactory = interface
        function build() : IDependencyAware;
    end;

implementation
end.
