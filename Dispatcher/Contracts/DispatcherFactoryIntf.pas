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
        ['{13BA047B-BE9D-442C-A4BC-957A06BD291D}']
        function build() : IDependencyAware;
    end;

implementation
end.
