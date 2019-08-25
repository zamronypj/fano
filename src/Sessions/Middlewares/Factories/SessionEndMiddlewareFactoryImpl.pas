(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-app-middleware
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionEndMiddlewareFactoryImpl;

interface

uses

    DependencyContainerIntf,
    DependencyIntf,
    SessionManagerIntf,
    CookieFactoryIntf,
    FactoryImpl;

type

    TSessionEndMiddlewareFactory = class(TFactory, IDependencyFactory)
    private
        fSessionMgr : ISessionManager;
        fCookieFactory : ICookieFactory;
    public
        constructor create(
            const sessMgr : ISessionManager;
            const cookieFactory : ICookieFactory
        );
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    SessionEndMiddlewareImpl;

    constructor TSessionEndMiddlewareFactory.create(
        const sessMgr : ISessionManager;
        const cookieFactory : ICookieFactory
    );
    begin
        inherited create();
        fSessionMgr := sessMgr;
        fCookieFactory := cookieFactory;
    end;

    destructor TSessionEndMiddlewareFactory.destroy();
    begin
        fSessionMgr := nil;
        fCookieFactory := nil;
        inherited destroy();
    end;

    function TSessionEndMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TSessionEndMiddleware.create(fSessionMgr, fCookieFactory);
    end;
end.
