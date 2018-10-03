unit DependencyListImpl;

interface

uses
    DependencyListIntf,
    HashListImpl;

type
    {------------------------------------------------
     interface for any class having capability to
     store depdendency
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDependencyList = class(THashList, IDependencyList)
    end;

implementation
end.
