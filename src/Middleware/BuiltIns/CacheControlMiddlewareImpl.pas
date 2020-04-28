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

uses

    md5,
    NullResponseStreamImpl;

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
    var svrETag : string;
        clientEtag : string;
    begin
        result := nextMdlwr.handleRequest(request, response, args);
        if (request.method = 'GET') or (request.method ='HEAD')  then
        begin
            if not result.headers.has('Cache-Control') then
            begin
                result.headers.addHeaderLine(fCache.serialize());
            end;
            svrETag = '';
            if request.headers.has('If-None-Match') then
            begin
                clientETag := request.headers.getHeader('If-None-Match');
                if result.headers.has('ETag') then
                begin
                    svrETag := result.headers.getHeader('ETag');
                    if clientETag = svrETag then
                    begin
                        //remove body and replace with HTTP 304
                        result.setBody(TNullResponseStream.create())
                            .headers.setHeader('Status', '304 Not Modified');
                    end;
                end else if (fCache.useETag) then
                begin
                    svrETag := MD5Print(MD5String(result.body.read()));
                    if clientETag = svrETag then
                    begin
                        //remove body and replace with HTTP 304
                        result.setBody(TNullResponseStream.create())
                            .headers.setHeader('Status', '304 Not Modified');
                    end;
                end;
            end;

            if (fCache.useETag) then
            begin
                if (svrETag = '') then
                begin
                    svrETag := MD5Print(MD5String(result.body.read()));
                end;
                result.headers.addHeader('ETag', '"' + tag + '"');
            end;
        end;
    end;
end.
