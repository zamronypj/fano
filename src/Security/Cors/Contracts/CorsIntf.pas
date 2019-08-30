{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CorsIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    HeadersIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * generate token to protect Cross-Site Request Forgery
     * (CSRF) attack
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    ICors = interface
        ['{E491F183-82E4-4A46-8B5E-38A965CC44B3}']

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
        function isPreflightRequest(const requestHeaders : IHeaders) : boolean;

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

end.
