unit MiddlewareChainFactoryIntf;

interface

uses
   MiddlewareChainIntf,
   MiddlewareCollectionIntf;

type
    {*!
     interface for any class having capability to create
     middleware chain instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    IMiddlewareChainFactory = interface
        ['{3D57F1EB-46CD-4D63-B77B-D51C656139EE}']

        function build(
            const appBeforeMiddlewares : IMiddlewareCollection;
            const appAfterMiddlewares : IMiddlewareCollection;
            const routeBeforeMiddlewares : IMiddlewareCollection;
            const routeAfterMiddlewares : IMiddlewareCollection
        ) : IMiddlewareChain;
    end;

implementation
end.
