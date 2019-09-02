{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CorsImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * handle CORS request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCors = class(TInterfacedObject, ICors)
    private
        fConfig : ICorsConfig;

        (*!------------------------------------------------
         * test of current request is in same host
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is same host
         *-------------------------------------------------*)
        function isSameHost(const request : IRequest) : boolean;
    public
        constructor create(const config : ICorsConfig);
        destructor destroy(); override;

        (*!------------------------------------------------
         * test of current request is allowed
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is allowed
         *-------------------------------------------------*)
        function isAllowed(const requestHeaders : IHeaders) : boolean;

        (*!------------------------------------------------
         * test of current request is CORS request
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is CORS request
         *-------------------------------------------------*)
        function isCorsRequest(const requestHeaders : IRequest) : boolean;

        (*!------------------------------------------------
         * test of current request is preflight request
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is preflight request
         *-------------------------------------------------*)
        function isPreflightRequest(const request : IRequest) : boolean;

        (*!------------------------------------------------
         * handle prefight request
         *-------------------------------------------------
         * @param response current response object
         * @param request current request object
         * @return response
         *-------------------------------------------------*)
        function handlePreflightRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse;

        (*!------------------------------------------------
         * add CORS header to response headers
         *-------------------------------------------------
         * @param responseHeaders response header
         * @param requestHeaders request header
         * @return current instance
         *-------------------------------------------------*)
        function addCorsHeaders(
            const responseHeaders : IHeaders;
            const requestHeaders : IHeaders
        ) : ICors;
    end;

implementation

uses

    SysUtils,
    StrUtils;

    constructor TCors.create(const config : ICorsConfig);
    begin
        fConfig := config;
    end;

    destructor TCors.destroy();
    begin
        fConfig := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * test of current request is allowed
     *-------------------------------------------------
     * @param requestHeaders request header
     * @return true if request is allowed
     *-------------------------------------------------*)
    function TCors.isAllowed(const request : IRequest) : boolean;
    var origin : string;
    begin
        if (matchStr('*', fAllowedOrigins)) then
        begin
            result := true;
        end;

        origin := request.headers().getHeader('Origin');
        if (matchStr(origin, fAllowedOrigins)) then
        begin
            result := true;
        end;

    end;

    (*!------------------------------------------------
     * test of current request is in same host
     *-------------------------------------------------
     * @param requestHeaders request header
     * @return true if request is same host
     *-------------------------------------------------*)
    function TCors.isSameHost(const request : IRequest) : boolean;
    var origin, schemeAndHost : string;
    begin
        origin := request.headers().getHeader('Origin');
        schemeAndHost := request.env.requestScheme() + '//' + request.env.httpHost();
        result := (origin = schemeAndHost);
    end;

    (*!------------------------------------------------
     * test of current request is CORS request
     *-------------------------------------------------
     * @param requestHeaders request
     * @return true if request is CORS request
     *-------------------------------------------------*)
    function TCors.isCorsRequest(const request : IRequest) : boolean;
    begin
        result := request.headers().has('Origin') and (not isSameHost(request));
    end;

    (*!------------------------------------------------
     * test of current request is preflight request
     *-------------------------------------------------
     * @param requestHeaders request header
     * @return true if request is preflight request
     *-------------------------------------------------*)
    function TCors.isPreflightRequest(const request : IRequest) : boolean;
    begin
        result := isCorsRequest(request) and
            (request.method = 'OPTIONS') and
            request.headers().has('Access-Control-Request-Method');
    end;

    (*!------------------------------------------------
     * handle prefight request
     *-------------------------------------------------
     * @param response current response object
     * @param request current request object
     * @return response
     *-------------------------------------------------*)
    function TCors.handlePreflightRequest(
        const request : IRequest;
        const response : IResponse
    ) : IResponse;
    var respHeaders : IHeaders;
    begin
        respHeaders := response.headers();
        respHeaders.setHeader(
            'Access-Control-Allow-Origin',
            request.headers().getHeader('Origin')
        );

        if (fSupportsCredentials) then
        begin
            respHeaders.setHeader('Access-Control-Allow-Credentials', 'true');
        end;

        if (fMaxAge > 0) then
        begin
            respHeaders.setHeader('Access-Control-Max-Age', intostr(fMaxAge));
        end;

        if (length(fAllowedMethods > 0)) then
        begin
            respHeaders.setHeader('Access-Control-Request-Method', fAllowedMethods.join(', '));
        end;

        if (length(fAllowedHeaders > 0)) then
        begin
            respHeaders.setHeader('Access-Control-Request-Headers', fAllowedHeaders.join(', '));
        end;

        result := response;
    end;

    (*!------------------------------------------------
     * add CORS header to response headers
     *-------------------------------------------------
     * @param responseHeaders response header
     * @param requestHeaders request header
     * @return response
     *-------------------------------------------------*)
    function TCors.addCorsHeaders(
        const response : IResponse;
        const request : IRequest
    ) : IResponse;
    var respHeaders : IHeaders;
    begin
        respHeaders := response.headers();
        respHeaders.setHeader(
            'Access-Control-Allow-Origin',
            request.headers().getHeader('Origin')
        );
        if (not respHeaders.has('Vary')) then
        begin
            respHeaders.setHeader('Vary', 'Origin');
        end else
        begin
            respHeaders.setHeader('Vary', respHeaders.getHeader('Vary') + ', Origin');
        end;

        if (fSupportsCredentials) then
        begin
            respHeaders.setHeader('Access-Control-Allow-Credentials', 'true');
        end;

        if (length(fExposedHeaders> 0)) then
        begin
            respHeaders.setHeader('Access-Control-Expose-Headers', fExposedHeaders.join(', '));
        end;

        result := response;
    end;

end.
