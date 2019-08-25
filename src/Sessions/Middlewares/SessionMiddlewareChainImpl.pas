{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionMiddlewareChainImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    RequestHandlerIntf,
    SessionManagerIntf,
    CookieFactoryIntf,
    MiddlewareChainIntf;

type

    (*!------------------------------------------------
     * decorator middleware chain that support session
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSessionMiddlewareChain = class(TInterfacedObject, IMiddlewareChain)
    private
        fActualMiddlewareChain : IMiddlewareChain;
        fSessionMgr : ISessionManager;
        fCookieFactory : ICookieFactory;
        fExpiresInSec : integer;
    public
        constructor create(
            const actualMiddlewareChain : IMiddlewareChain;
            const sessionMgr : ISessionManager;
            const cookieFactory : ICookieFactory;
            const expireInSec : integer
        );
        destructor destroy(); override;

        function execute(
            const request : IRequest;
            const response : IResponse;
            const requestHandler : IRequestHandler
        ) : IResponse;
    end;

implementation

uses

    SessionIntf,
    SessionResponseImpl;

    constructor TSessionMiddlewareChain.create(
        const actualMiddlewareChain : IMiddlewareChain;
        const sessionMgr : ISessionManager;
        const cookieFactory : ICookieFactory;
        const expireInSec : integer
    );
    begin
        inherited create();
        fActualMiddlewareChain := actualMiddlewareChain;
        fSessionMgr := sessionMgr;
        fCookieFactory := cookieFactory;
        fExpiresInSec := expireInSec;
    end;

    destructor TSessionMiddlewareChain.destroy();
    begin
        fActualMiddlewareChain := nil;
        fSessionMgr := nil;
        fCookieFactory := nil;
        inherited destroy();
    end;

    function TSessionMiddlewareChain.execute(
        const request : IRequest;
        const response : IResponse;
        const requestHandler : IRequestHandler
    ) : IResponse;
    var sess : ISession;
        newResp : IResponse;
    begin
        sess := fSessionMgr.beginSession(request, fExpiresInSec);
        newResp := fActualMiddlewareChain.execute(request, response, requestHandler);
        fSessionMgr.endSession(sess);
        result := TSessionResponse.create(newResp, sess, fCookieFactory);
    end;
end.
