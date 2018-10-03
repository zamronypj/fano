unit DispatcherFactoryIntf;

interface

uses
    DependencyAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability
     to build dispatcher instance
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDispatcherFactory = interface
        function build() : IDependencyAware;
    end;

implementation
end.
