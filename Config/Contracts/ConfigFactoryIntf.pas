unit ConfigFactoryIntf;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     get config
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IAppConfigurationFactory = interface(IDependencyFactory)
        ['{52972D1B-CB7A-447B-9437-56D2C9063B5D}']
    end;

implementation
end.
