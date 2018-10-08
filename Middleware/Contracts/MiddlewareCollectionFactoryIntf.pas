unit MiddlewareCollectionFactoryIntf;

interface

uses
    DependencyFactoryIntf;

type
    {*!
     interface for any class having capability to create
     middleware collection instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    IMiddlewareCollectionFactory = interface(IDependencyFactory)
        ['{2BDD325A-1881-4202-8B12-3046C12D8D95}']
    end;

implementation
end.
