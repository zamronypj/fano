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
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * middleware implementation that add
     * WWW-Authenticate header
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TBasicAuthMiddleware = class(TInjectableObject, IMiddleware)
    private
        fRealm : string;
        fAuth : IAuth;
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
    begin
        if fAuth.auth(request, response, args) then
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
