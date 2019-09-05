{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionMiddlewareChainFactoryImpl;

interface

{$MODE OBJFPC}

uses

   MiddlewareChainIntf,
   MiddlewareChainFactoryIntf,
   MiddlewareCollectionAwareIntf,
   SessionManagerIntf,
   CookieFactoryIntf;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionMiddlewareChainFactory = class(TInterfacedObject, IMiddlewareChainFactory)
    private
        fActualFactory : IMiddlewareChainFactory;
        fSessionMgr : ISessionManager;
        fCookieFactory : ICookieFactory;
        fExpiresInSec : integer;
    public
        constructor create(
            const actualFactory : IMiddlewareChainFactory;
            const sessionMgr : ISessionManager;
            const cookieFactory : ICookieFactory;
            const expiresInSec : integer
        );
        destructor destroy(); override;

        function build(
            const appMiddlewares : IMiddlewareCollectionAware;
            const routeMiddlewares : IMiddlewareCollectionAware
        ) : IMiddlewareChain;
    end;

implementation

uses

    SessionMiddlewareChainImpl;

    constructor TSessionMiddlewareChainFactory.create(
        const actualFactory : IMiddlewareChainFactory;
        const sessionMgr : ISessionManager;
        const cookieFactory : ICookieFactory;
        const expiresInSec : integer
    );
    begin
        inherited create();
        fActualFactory := actualFactory;
        fSessionMgr := sessionMgr;
        fCookieFactory := cookieFactory;
        fExpiresInSec := expiresInSec;
    end;

    destructor TSessionMiddlewareChainFactory.destroy();
    begin
        fActualFactory := nil;
        fSessionMgr := nil;
        fCookieFactory := nil;
        inherited destroy();
    end;

    function TSessionMiddlewareChainFactory.build(
        const appMiddlewares : IMiddlewareCollectionAware;
        const routeMiddlewares : IMiddlewareCollectionAware
    ) : IMiddlewareChain;
    begin
        result := TSessionMiddlewareChain.create(
            fActualFactory.build(appMiddlewares, routeMiddlewares),
            fSessionMgr,
            fCookieFactory,
            fExpiresInSec
        );
    end;
end.
