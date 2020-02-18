{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DigestAuthMiddlewareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    MiddlewareIntf,
    RequestIntf,
    ResponseIntf,
    HeadersIntf,
    RouteArgsReaderIntf,
    RequestHandlerIntf,
    AuthIntf,
    RandomIntf,
    InjectableObjectImpl,
    DigestInfoTypes,
    CredentialTypes;

type

    (*!------------------------------------------------
     * middleware implementation that authenticate using
     * Digest Authentication (RFC 2617)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TDigestAuthMiddleware = class(TInjectableObject, IMiddleware)
    private
        fRandom : IRandom;

        //basic authentication realm
        fRealm : string;

        //instance of class responsible to authenticate credential
        fAuth : IAuth;

        (*!------------------------------------------------
         * extract credential from Basic Authentatication
         *-------------------------------------------------
         * @param request current request object
         * @param foundCredential extracted credential
         * @return boolean true if credential succesfully read
         *-------------------------------------------------*)
        function getCredential(
            const request : IRequest;
            out foundCredential : TCredential
        ) : boolean;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param auth object responsible to authenticate
         * @param realm string of realm value
         *-------------------------------------------------*)
        constructor create(
            const randomObj : IRandom;
            const auth : IAuth;
            const realm : string
        );

        (*!------------------------------------------------
         * destructor
         *-------------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * handle authentication
         *-------------------------------------------------
         * @param request current request object
         * @param response current response object
         * @param args route argument reader
         * @param next next middleware to run
         * @return response
         *-------------------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader;
            const next : IRequestHandler
        ) : IResponse;
    end;

implementation

uses

    SysUtils,
    Md5,
    HttpCodeResponseImpl,
    DigestInfoHelper;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param randomObj object responsible to generate random bytes
     * @param auth object responsible to authenticate
     * @param realm string of realm value
     *-------------------------------------------------*)
    constructor TDigestAuthMiddleware.create(
        const randomObj : IRandom;
        const auth : IAuth;
        const realm : string
    );
    begin
        inherited create();
        fRandom := randomObj;
        fAuth := auth;
        fRealm := realm;
    end;

    (*!------------------------------------------------
     * destructor
     *-------------------------------------------------*)
    destructor TDigestAuthMiddleware.destroy();
    begin
        fRandom := nil;
        fAuth := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * extract credential from Basic Authentatication
     *-------------------------------------------------
     * @param request current request object
     * @param foundCredential extracted credential
     * @return boolean true if credential succesfully read
     *-------------------------------------------------*)
    function TDigestAuthMiddleware.getCredential(
        const request : IRequest;
        out foundCredential : TCredential
    ) : boolean;
    const
        DIGEST_STR = 'digest ';
    var
        authHeaderLine : string;
        digestInfo : TDigestInfo;
    begin
        result := false;
        foundCredential.username := '';
        foundCredential.password := '';
        foundCredential.data := nil;

        if request.headers().has('Authorization') then
        begin
            authHeaderLine := request.headers().getHeader('Authorization');
            if pos(DIGEST_STR, trimLeft(lowercase(authHeaderLine))) = 1 then
            begin
                digestInfo := getDigestInfo(request.method, authHeaderLine);
                if (fRealm = digestInfo.realm) then
                begin
                    //only continue if realm matched
                    foundCredential.username := digestInfo.username;
                    foundCredential.password := digestInfo.response;
                    foundCredential.data := @digestInfo;
                    result := true;
                end;
            end;
        end;
    end;

    (*!------------------------------------------------
     * handle authentication
     *-------------------------------------------------
     * @param request current request object
     * @param response current response object
     * @param args route argument reader
     * @param next next middleware to run
     * @return response
    *-------------------------------------------------*)
    function TDigestAuthMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        const next : IRequestHandler
    ) : IResponse;
    var cred : TCredential;
        nonce, opaque : string;
        rndValue : TBytes;
    begin
        if getCredential(request, cred) and fAuth.auth(cred) then
        begin
            //continue to next middleware
            result := next.handleRequest(request, response, args);
        end else
        begin
            rndValue := fRandom.randomBytes(32);
            nonce := MD5Print(MD5Buffer(rndValue, length(rndValue));
            rndValue := fRandom.randomBytes(32);
            opaque := MD5Print(MD5Buffer(rndValue, length(rndValue));

            result := THttpCodeResponse.create(
                401,
                'Unauthorized',
                response.headers()
            );
            result.headers().setHeader(
                'WWW-Authenticate',
                format(
                    'Digest realm="%s", qop="auth,auth-int", nonce="%s", opaque="%s"',
                    [ fRealm, nonce, opaque ]
                )
            );
        end;
    end;

end.
