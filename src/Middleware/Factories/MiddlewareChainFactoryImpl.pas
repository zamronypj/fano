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
    MiddlewareCollectionAwareIntf;

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
            const appMiddlewares : IMiddlewareCollectionAware;
            const routeMiddlewares : IMiddlewareCollectionAware
        ) : IMiddlewareChain;
    end;

implementation

uses
    MiddlewareChainImpl;

    function TMiddlewareChainFactory.build(
        const appMiddlewares : IMiddlewareCollectionAware;
        const routeMiddlewares : IMiddlewareCollectionAware
    ) : IMiddlewareChain;
    begin
        result := TMiddlewareChain.create(
            appMiddlewares.getBefore(),
            appMiddlewares.getAfter(),
            routeMiddlewares.getBefore(),
            routeMiddlewares.getAfter()
        );
    end;
end.
