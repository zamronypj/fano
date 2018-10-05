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
    ICGIEnvironmentFactory = interface
        ['{7A704545-F34F-4854-9CEB-1E0797CC5757}']
        function build() : IDependencyAware;
    end;

implementation
end.
