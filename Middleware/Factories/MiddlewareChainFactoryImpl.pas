{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareChainFactoryImpl;

interface

{$MODE OBJFPC}

uses

   MiddlewareChainIntf,
   MiddlewareChainFactoryIntf,
   MiddlewareCollectionIntf;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
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
