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
        constructor create(const realm : string);
        destructor destroy(); override;

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

    constructor TBasicAuthMiddleware.create(
        const auth : IAuth;
        const realm : string
    );
    begin
        inherited create();
        fAuth := auth;
        fRealm := realm;
    end;

    destructor TBasicAuthMiddleware.destroy();
    begin
        fAuth := nil;
        inherited destroy();
    end;

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
