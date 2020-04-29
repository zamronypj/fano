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
        function isCacheable(
            const request : IRequest;
            const response : IResponse
        ) : boolean;
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
    NotModifiedResponseImpl;

    constructor TCacheControlMiddleware.create(const cache : IHttpCache);
    begin
        fCache := cache;
    end;

    destructor TCacheControlMiddleware.destroy();
    begin
        fCache := nil;
        inherited destroy();
    end;

    function TCacheControlMiddleware.isCacheable(
        const request : IRequest;
        const response : IResponse
    ) : boolean;
    begin
        result := ((request.method = 'GET') or (request.method ='HEAD')) and
            (response.body().size() > 0);
    end;

    function TCacheControlMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        const nextMdlwr : IRequestHandler
    ) : IResponse;
    var svrETag : string;
        clientEtag : string;
        notModified : boolean;
        lastModified, ifModifiedSince : TDateTime;
    begin
        result := nextMdlwr.handleRequest(request, response, args);
        if isCacheable(request, result) then
        begin
            notModified := false;
            if not result.headers.has('Cache-Control') then
            begin
                result.headers.addHeaderLine(fCache.serialize());
            end;

            svrETag = '';

            if request.headers.has('If-None-Match') then
            begin
                clientETag := request.headers['If-None-Match'];
                if result.headers.has('ETag') then
                begin
                    svrETag := result.headers['ETag'];
                end else if (fCache.useETag) then
                begin
                    svrETag := MD5Print(MD5String(result.body.read()));
                    result.headers.addHeader('ETag', '"' + svrETag + '"');
                end;

                if (clientETag = svrETag) or (clientETag = '"*"') then
                begin
                    notModified := true;
                end;
            end;

            if response.headers.has('Last-Modified') then
            begin
                if (request.headers.has('If-Modified-Since')) then
                begin
                    lastModified := scanDateTime(
                        'ddd, dd mmm yyyy hh:mm:ss',
                        response.headers['Last-Modified']
                    );
                    ifModifiedSince := scanDateTime(
                        'ddd, dd mmm yyyy hh:mm:ss',
                        response.headers['If-Modified-Since']
                    );
                    notModified := ifModifiedSince >= lastModified;
                end;
            end;

            if notModified then
            begin
                result := TNotModifiedResponse.create(result.headers);
            end;
        end;
    end;
end.
