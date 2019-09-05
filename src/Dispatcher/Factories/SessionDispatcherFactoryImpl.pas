{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionDispatcherFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RouteMatcherIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareChainFactoryIntf,
    RequestResponseFactoryIntf,
    SessionManagerIntf,
    CookieFactoryIntf,
    DispatcherFactoryImpl;

type

    (*!--------------------------------------------------
     * factory class for TDispatcher,
     * route dispatcher implementation which support middleware
     * and session
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TSessionDispatcherFactory = class(TDispatcherFactory)
    private
        fSessionMgr : ISessionManager;
        fCookieFactory : ICookieFactory;
        fExpiresInSec : integer;
    protected
        function createMiddlewareChainFactory() : IMiddlewareChainFactory; override;
    public
        constructor create (
            const appMiddlewaresInst : IMiddlewareCollectionAware;
            const routeMatcherInst : IRouteMatcher;
            const requestResponseFactory : IRequestResponseFactory;
            const sessionMgr : ISessionManager;
            const cookieFactory : ICookieFactory;
            const expiresInSec : integer
        );

        destructor destroy(); override;
    end;

implementation

uses

    SessionMiddlewareChainFactoryImpl;

    constructor TSessionDispatcherFactory.create (
        const appMiddlewaresInst : IMiddlewareCollectionAware;
        const routeMatcherInst : IRouteMatcher;
        const requestResponseFactory : IRequestResponseFactory;
        const sessionMgr : ISessionManager;
        const cookieFactory : ICookieFactory;
        const expiresInSec : integer
    );
    begin
        inherited create(appMiddlewaresInst, routeMatcherInst, requestResponseFactory);
        fSessionMgr := sessionMgr;
        fCookieFactory := cookieFactory;
        fExpiresInSec := expiresInSec;
    end;

    destructor TSessionDispatcherFactory.destroy();
    begin
        fSessionMgr := nil;
        fCookieFactory := nil;
        inherited destroy();
    end;

    function TSessionDispatcherFactory.createMiddlewareChainFactory() : IMiddlewareChainFactory;
    var actualFactory : IMiddlewareChainFactory;
    begin
        actualFactory := inherited createMiddlewareChainFactory();
        result := TSessionMiddlewareChainFactory.create(
            actualFactory,
            fSessionMgr,
            fCookieFactory,
            fExpiresInSec
        );
    end;

end.
