unit MiddlewareChainFactoryImpl;

interface

uses
   MiddlewareChainIntf,
   MiddlewareChainFactoryIntf,
   MiddlewareCollectionIntf;

type
    {*!
     basic class having capability to create
     middleware chain instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TMiddlewareChainFactory = class(TInterfacedObject, IMiddlewareChainFactory)
    public
        function build(
            const appBeforeMiddlewares : IMiddlewareCollection;
            const appAfterMiddlewares : IMiddlewareCollection;
            const routeBeforeMiddlewares : IMiddlewareCollection;
            const routeAfterMiddlewares : IMiddlewareCollection
        ) : IMiddlewareChain;
    end;

implementation

uses
    MiddlewareChainImpl;

    function TMiddlewareChainFactory.build(
        const appBeforeMiddlewares : IMiddlewareCollection;
        const appAfterMiddlewares : IMiddlewareCollection;
        const routeBeforeMiddlewares : IMiddlewareCollection;
        const routeAfterMiddlewares : IMiddlewareCollection
    ) : IMiddlewareChain;
    begin
        result := TMiddlewareChain.create(
            appBeforeMiddlewares,
            appAfterMiddlewares,
            routeBeforeMiddlewares,
            routeAfterMiddlewares
        );
    end;
end.
