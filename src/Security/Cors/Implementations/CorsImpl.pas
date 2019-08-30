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
        (*!------------------------------------------------
         * test of current request is in same host
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is same host
         *-------------------------------------------------*)
        function isSameHost(const request : IRequest) : boolean;
    public

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
        function isCorsRequest(const requestHeaders : IHeaders) : boolean;

        (*!------------------------------------------------
         * test of current request is preflight request
         *-------------------------------------------------
         * @param requestHeaders request header
         * @return true if request is preflight request
         *-------------------------------------------------*)
        function isPreflightRequest(const request : IRequest) : boolean;

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

    (*!------------------------------------------------
     * test of current request is allowed
     *-------------------------------------------------
     * @param requestHeaders request header
     * @return true if request is allowed
     *-------------------------------------------------*)
    function TCors.isAllowed(const requestHeaders : IHeaders) : boolean;
    begin
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
    function TCors.isPreflightRequest(const requestHeaders : IHeaders) : boolean;
    begin
    end;

    (*!------------------------------------------------
     * add CORS header to response headers
     *-------------------------------------------------
     * @param responseHeaders response header
     * @param requestHeaders request header
     * @return current instance
     *-------------------------------------------------*)
    function TCors.addCorsHeaders(
        const responseHeaders : IHeaders;
        const requestHeaders : IHeaders
    ) : ICors;
    begin
    end;

end.
