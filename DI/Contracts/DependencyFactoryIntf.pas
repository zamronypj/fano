unit DependencyFactoryIntf;

interface

uses
    DependencyIntf;

type
    {------------------------------------------------
     interface for any class
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyFactory = interface
        ['{BB858A2C-65DD-47C6-9A04-7C4CCA2816DD}']
        function build() : IDependency;
    end;

implementation
end.
