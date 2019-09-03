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
        function handlePreflightRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
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

    function TCorsMiddleware.handlePreflightRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    begin
        if (fCors.isPreflightRequest(request)) then
        begin
            canContinue := false;
            result := fCors.handlePreflightRequest(request, response);
        end else
        begin
            if (not fCors.isAllowed(request)) then
            begin
                canContinue := false;
                result := THttpCodeResponse.create(403, 'Not allowed', response.headers());
            end else
            begin
                fCors.addCorsResponseHeaders(request, response);
                result := response;
            end;
        end;
    end;

    function TCorsMiddleware.handleRequest(
          const request : IRequest;
          const response : IResponse;
          var canContinue : boolean
    ) : IResponse;
    begin
        if (not fCors.isCorsRequest(request)) then
        begin
            result := response;
        end else
        begin
            result := handlePreflightRequest(request, response, canContinue);
        end;
    end;

end.
