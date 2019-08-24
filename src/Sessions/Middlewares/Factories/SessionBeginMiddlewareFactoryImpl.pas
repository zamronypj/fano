(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-app-middleware
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionBeginMiddlewareFactoryImpl;

interface

uses

    DependencyContainerIntf,
    DependencyIntf,
    SessionManagerIntf,
    FactoryImpl;

type

    TSessionBeginMiddlewareFactory = class(TFactory, IDependencyFactory)
    private
        fSessionMgr : ISessionManager;
        fExpiresInSec : integer;
    public
        constructor create(const sessMgr : ISessionManager; const expiresInSec : integer);
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    SessionBeginMiddlewareImpl;

    constructor TSessionBeginMiddlewareFactory.create(
        const sessMgr : ISessionManager;
        const expiresInSec : integer
    );
    begin
        inherited create();
        fSessionMgr := sessMgr;
        fExpiresInSec := expiredInSec
    end;

    destructor TSessionBeginMiddlewareFactory.destroy();
    begin
        fSessionMgr := nil;
        inherited destroy();
    end;

    function TSessionBeginMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TSessionBeginMiddleware.create(fSessionMgr, fExpiresInSec);
    end;
end.
