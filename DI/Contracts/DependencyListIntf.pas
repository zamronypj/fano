unit DependencyListIntf;

interface

uses
    HashListIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     dependencies
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IDependencyList = interface(IHashList)
        ['{BBDB53E2-D4DF-4FD0-86D4-2291124236B1}']
    end;

implementation
end.
