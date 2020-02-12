{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit BasicAuthMiddlewareImpl;

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
    InjectableObjectImpl,
    CredentialTypes;

type

    (*!------------------------------------------------
     * middleware implementation that authenticate using
     * Basic Authentication (RFC 2617)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TBasicAuthMiddleware = class(TInjectableObject, IMiddleware)
    private
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

    HttpCodeResponseImpl;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param auth object responsible to authenticate
     * @param realm string of realm value
     *-------------------------------------------------*)
    constructor TBasicAuthMiddleware.create(
        const auth : IAuth;
        const realm : string
    );
    begin
        inherited create();
        fAuth := auth;
        fRealm := realm;
    end;

    (*!------------------------------------------------
     * destructor
     *-------------------------------------------------*)
    destructor TBasicAuthMiddleware.destroy();
    begin
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
    function TBasicAuthMiddleware.getCredential(
        const request : IRequest;
        out foundCredential : TCredential
    ) : boolean;
    var
        authHeaderLine : string;
        credential : string;
        colonPos : integer;
    begin
        result := false;
        foundCredential.username := '';
        foundCredential.password := '';

        if request.headers().has('Authorization') then
        begin
            authHeaderLine := request.headers().getHeader('Authorization');
            if pos('basic ', lowercase(authHeaderLine)) = 1 then
            begin
                credential := decodeStringBase64(
                    copy(
                        authHeaderLine,
                        7,
                        length(authHeaderLine) - 7
                    )
                );

                colonPos := pos(':', credential);
                if colonPos <> 0 then
                begin
                    foundCredential.username := copy(credential, 1, colonPos);
                    foundCredential.password := copy(credential, colonPos, length(credential) - colonPos);
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
    function TBasicAuthMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        const next : IRequestHandler
    ) : IResponse;
    var cred : TCredential;
    begin
        if getCredential(request, cred) and fAuth.auth(cred) then
        begin
            //continue to next middleware
            result := next.handleRequest(request, response, args);
        end else
        begin
            result := THttpCodeResponse.create(
                401,
                'Unauthorized',
                response.headers().clone()
            );
            result.headers().setHeader(
                'WWW-Authenticate',
                'Basic realm="' + fRealm + '"'
            );
        end;
    end;

end.
