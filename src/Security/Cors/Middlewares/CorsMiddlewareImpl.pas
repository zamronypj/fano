{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit CorsMiddlewareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    MiddlewareIntf,
    RequestIntf,
    ResponseIntf,
    HeadersIntf,
    InjectableObjectImpl,
    CorsIntf;

type

    (*!------------------------------------------------
     * middleware implementation that add CORS header
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCorsMiddleware = class(TInjectableObject, IMiddleware)
    private
        fCors : ICors;
    public
        constructor create(const cors : ICors);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

uses

    HttpCodeResponseImpl;

    constructor TCorsMiddleware.create(const cors : ICors);
    begin
        inherited create();
        fCors := nil;
    end;

    destructor TCorsMiddleware.destroy();
    begin
        fCors := nil;
        inherited destroy();
    end;

    function TCorsMiddleware.handleRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    var rejectReason : string;
        httpCode : word;
    begin
        httpCode := 403;
        rejectReason := 'Origin not allowed';

        canContinue := fCors.isAllowed(request.headers());
        if canContinue then
        begin
            fCors.addCorsHeaders(response.headers(), request.headers());
            result := response;
        end else
        begin
            result := THttpCodeResponse.create(403, rejectReason)
        end;
    end;

end.
