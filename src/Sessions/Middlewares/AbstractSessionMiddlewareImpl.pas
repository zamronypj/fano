(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-session
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit AbstractSessionMiddlewareImpl;

interface

uses

    MiddlewareIntf,
    SessionManagerIntf,
    RequestIntf,
    ResponseIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * middleware implementation that manages session
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAbstractSessionMiddleware = class(TInjectableObject, IMiddleware)
    protected
        fSessionMgr : ISessionManager;
    public
        constructor create(const sessionMgr : ISessionManager);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse; virtual; abstract;
    end;

implementation

    constructor TAbstractSessionMiddleware.create(const sessionMgr : ISessionManager);
    begin
        inherited create();
        fSessionMgr := sessionMgr;
    end;

    destructor TAbstractSessionMiddleware.destroy();
    begin
        fSessionMgr := nil;
        inherited destroy();
    end;

end.
