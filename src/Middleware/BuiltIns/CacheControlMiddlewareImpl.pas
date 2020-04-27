{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CacheControlMiddlewareImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    RouteArgsReaderIntf,
    RequestHandlerIntf,
    HttpCacheIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * midlleware class that add Cache-Control (RFC 7234)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCacheControlMiddleware = class(TInjectableObject, IMiddleware)
    private
        fCache : IHttpCache;
    public
        constructor create(const cache : IHttpCache);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader;
            const nextMdlwr : IRequestHandler
        ) : IResponse;
    end;

implementation

    constructor TCacheControlMiddleware.create(const cache : IHttpCache);
    begin
        fCache := cache;
    end;

    destructor TCacheControlMiddleware.destroy();
    begin
        fCache := nil;
        inherited destroy();
    end;

    function TCacheControlMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        const nextMdlwr : IRequestHandler
    ) : IResponse;
    begin
        if response.headers.has('Cache-Control') then
        begin
            result := nextMdlwr.handleRequest(request, response, args);
        end else
        begin
            response.headers.addHeaderLine(fCache.serialize());
            result := nextMdlwr.handleRequest(request, response, args);
        end;
    end;
end.
