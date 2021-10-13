{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionMiddlewareFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    SessionManagerIntf,
    CookieFactoryIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * factory class for TSessionMiddleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionMiddlewareFactory = class(TFactory, IDependencyFactory)
    private
        fSessionMgr : ISessionManager;
        fCookieFactory : ICookieFactory;
        fExpiresInSec : integer;
    public
        constructor create();

        function expiresInSec(const aExpiresInSec : integer) : TSessionMiddlewareFactory;
        function sessionManager(const aSessionMgr : ISessionManager) : TSessionMiddlewareFactory;
        function cookieFactory(const aCookieFactory : ICookieFactory) : TSessionMiddlewareFactory;

        (*!---------------------------------------
         * build middleware instance
         *----------------------------------------
         * @param container dependency container
         * @return instance of middleware
         *----------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    JsonFileSessionManagerFactoryImpl,
    CookieFactoryImpl,
    SessionMiddlewareImpl;

const

    EXPIRES_30_MIN = 30 * 60;

    constructor TSessionMiddlewareFactory.create();
    begin
        fSessionMgr := nil;
        fCookieFactory := nil;
        fExpiresInSec := EXPIRES_30_MIN;
    end;

    function TSessionMiddlewareFactory.expiresInSec(
        const aExpiresInSec : integer
    ) : TSessionMiddlewareFactory;
    begin
        fExpiresInSec := aExpiresInSec;
        result := self;
    end;

    function TSessionMiddlewareFactory.sessionManager(
        const aSessionMgr : ISessionManager
    ) : TSessionMiddlewareFactory;
    begin
        fSessionMgr := aSessionMgr;
        result := self;
    end;

    function TSessionMiddlewareFactory.cookieFactory(
        const aCookieFactory : ICookieFactory
    ) : TSessionMiddlewareFactory;
    begin
        fCookieFactory := aCookieFactory;
        result := self;
    end;


    function TSessionMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    var sessionManagerFactory : IDependencyFactory;
    begin
        if fSessionMgr = nil then
        begin
            sessionManagerFactory := TJsonFileSessionManagerFactory.create();
            fSessionMgr := sessionManagerFactory.build(container) as ISessionManager;
        end;

        if fCookieFactory = nil then
        begin
            fCookieFactory := TCookieFactory.create();
        end;

        result := TSessionMiddleware.create(fSessionMgr, fCookieFactory, fExpiresInSec);
    end;

end.
