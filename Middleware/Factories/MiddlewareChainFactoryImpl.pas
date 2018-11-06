{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
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
