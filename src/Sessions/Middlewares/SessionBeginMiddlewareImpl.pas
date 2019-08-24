(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-session
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionBeginMiddlewareImpl;

interface

uses

    RequestIntf,
    ResponseIntf,
    SessionManagerIntf,
    AbstractSessionMiddlewareImpl;

type

    (*!------------------------------------------------
     * middleware implementation that initialize session
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionBeginMiddleware = class(TAbstractSessionMiddleware)
    private
        fExpiresInSec : integer;
    public
        constructor create(const sessionMgr : ISessionManager; const expireInSec : integer);

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse; override;
    end;

implementation

    constructor TSessionBeginMiddleware.create(
        const sessionMgr : ISessionManager;
        const expireInSec : integer
    );
    begin
        inherited create(sessionMgr);
        fExpiresInSec := expireInSec;
    end;

    function TSessionBeginMiddleware.handleRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    begin
        fSession.beginSession(request, fExpiresInSec);
        result := response;
    end;

end.
