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
    SessionIntf,
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

        function addCookieHeader(
            const resp : IResponse;
            const sess : ISession;
            const cookieFactory : ICookieFactory
        ) : IResponse;

        function executeAndAddCookie(
            const request : IRequest;
            const response : IResponse;
            const requestHandler : IRequestHandler;
            sess : ISession
        ) : IResponse;
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

    CookieIntf;

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

    function TSessionMiddlewareChain.addCookieHeader(
        const resp : IResponse;
        const sess : ISession;
        const cookieFactory : ICookieFactory
    ) : IResponse;
    var cookie : ICookie;
    begin
        cookie := cookieFactory.name(sess.name()).value(sess.id()).build();
        try
            resp.headers().setHeader('Set-Cookie', cookie.serialize());
            result := resp;
        finally
            cookie := nil;
        end;
    end;

    function TSessionMiddlewareChain.executeAndAddCookie(
        const request : IRequest;
        const response : IResponse;
        const requestHandler : IRequestHandler;
        sess : ISession
    ) : IResponse;
    var newResp : IResponse;
    begin
        newResp := fActualMiddlewareChain.execute(request, response, requestHandler);
        try
            result := addCookieHeader(newResp, sess, fCookieFactory);
        finally
            newResp := nil;
        end;
    end;

    function TSessionMiddlewareChain.execute(
        const request : IRequest;
        const response : IResponse;
        const requestHandler : IRequestHandler
    ) : IResponse;
    var sess : ISession;
    begin
        sess := fSessionMgr.beginSession(request, fExpiresInSec);
        try
            result := executeAndAddCookie(request, response, requestHandler, sess);
        finally
            fSessionMgr.endSession(sess);
            sess := nil;
        end;
    end;
end.
