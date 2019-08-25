(*!------------------------------------------------------------
 * Fano Web Framework Skeleton Application (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano-session
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano-app-middleware/blob/master/LICENSE (GPL 3.0)
 *------------------------------------------------------------- *)
unit SessionEndMiddlewareImpl;

interface

uses

    MiddlewareIntf,
    SessionManagerIntf,
    SessionIntf,
    RequestIntf,
    ResponseIntf,
    CookieFactoryIntf,
    AbstractSessionMiddlewareImpl;

type

    (*!------------------------------------------------
     * middleware implementation that persist session
     * data to storage at the end of request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSessionEndMiddleware = class(TAbstractSessionMiddleware)
    private
        fCookieFactory : ICookieFactory;
    public
        constructor create(
            const sessionMgr : ISessionManager;
            const cookieFactory : ICookieFactory
        );

        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse; override;
    end;

implementation

    constructor TSessionEndMiddleware.create(
        const sessionMgr : ISessionManager;
        const cookieFactory : ICookieFactory
    );
    begin
        inherited create(sessionMgr);
        fCookieFactory := cookieFactory;
    end;

    destructor TSessionEndMiddleware.destroy();
    begin
        fCookieFactory:= nil;
        inherited destroy();
    end;

    function TSessionEndMiddleware.handleRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    var sess : ISession;
    begin
        sess := fSession.getSession(request);
        fSession.endSession(sess);
        result := TSessionResponse.create(response, sess, fCookieFactory);
    end;

end.
