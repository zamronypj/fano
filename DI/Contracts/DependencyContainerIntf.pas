unit DependencyContainerIntf;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability to manage
     dependency

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyContainer = interface
        function add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function get(const serviceName : string) : IDependencyAware;
    end;

implementation
end.
