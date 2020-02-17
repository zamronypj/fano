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
    InjectableObjectImpl,
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

        function extractValue(const regex : IRegex; const key : string) : string;
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

    Base64,
    HttpCodeResponseImpl;

type

    TDigestInfo = record
        username : string;
        nonce : string;
        realm : string;
        uri : string;
        qop : string;
        nc : string;
        cnonce : string;
        response : string;
        opaque : string;
    end;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param auth object responsible to authenticate
     * @param realm string of realm value
     *-------------------------------------------------*)
    constructor TDigestAuthMiddleware.create(
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
    destructor TDigestAuthMiddleware.destroy();
    begin
        fAuth := nil;
        inherited destroy();
    end;

    procedure extractKeyValuePair(re : TRegExpr; out key : string; out value : string);
    var
        lastMatchLen : integer;
        comaPos : integer;
    begin
        key := re.match(1);
        lastMatchLen := re.matchLen();
        value := re.match(lastMatchLen);
        if lastMatchLen < 4 then
        begin
            //we dealing with unquoted value, value will contain trailing coma
            //remove them
            comaPos := pos(',', value);
            if (comaPos <> 0) then
            begin
                value := copy(value, 1, comapos);
            end;
        end
    end;

    function initEmptyDigestInfo() : TDigestInfo;
    begin
        with result do
        begin
            username := '';
            nonce := '';
            realm := '';
            uri := '';
            qop := '';
            nc := '';
            cnonce := '';
            response := '';
            opaque := '';
        end;
    end;

    function fillDigestInfo(const di : TDigestInfo; const key: string; const value : string) : TDigestInfo;
    begin
        with di do
        begin
            case key of
                'username' : username := value;
                'nonce' : nonce := value;
                'realm' : realm := value;
                'uri' : uri := value;
                'qop' : qop := value;
                'nc' : nc := value;
                'cnonce' : cnonce := value;
                'response' : response := value;
                'opaque' : opaque := value;
            end;
        end;
        result := di;
    end;

    function getDigestInfo(const authHeaderLine : string) : TDigestInfo;
    const REGEXPATTERN = '(\w+)[\s]*=[\s]*(([^"''\s]+)|''([^'']*)''|"([^"]*)")\s*,*';
    var re : TRegExpr;
        key, value : string;
    begin
        result := initEmptyDigestInfo();
        re := TRegExpr.create(REGEXPATTERN);
        try
            re.modifierG := true;
            re.modifierM := true;
            setLength(result.matches, 0);
            if re.exec(authHeaderLine) then
            begin
                extractKeyValuePair(re, key, value);
                result := fillDigestInfo(result, key, value);
                while (re.execNext()) do
                begin
                    extractKeyValuePair(re, key, value);
                    result := fillDigestInfo(result, key, value);
                end;
            end;
        finally
            re.free();
        end;
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
        DIGEST_STR_LEN = length(DIGEST_STR);
    var
        authHeaderLine : string;
        credential : string;
        digestInfo : TDigestInfo;
        HA1, HA2 : string;
    begin
        result := false;
        foundCredential.username := '';
        foundCredential.password := '';

        if request.headers().has('Authorization') then
        begin
            authHeaderLine := request.headers().getHeader('Authorization');
            if pos(DIGEST_STR, lowercase(authHeaderLine)) = 1 then
            begin
                digestInfo := getDigestInfo(authHeaderLine);
                foundCredential.username := digestInfo.username;
                foundCredential.password := digestInfo.response;
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
    begin
        if getCredential(request, cred) and fAuth.auth(cred) then
        begin
            //continue to next middleware
            result := next.handleRequest(request, response, args);
        end else
        begin
            nonce := generateNonce();
            opaque := generateOpaque();
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
