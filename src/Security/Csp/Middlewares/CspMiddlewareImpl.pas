{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CspMiddlewareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    RequestHandlerIntf,
    RouteArgsReaderIntf,
    InjectableObjectImpl,
    CspConstant;

type

    (*!------------------------------------------------
     * middleware that implement Content Security Policy
     *-------------------------------------------------
     * https://www.w3.org/TR/CSP/
     * https://content-security-policy.com/
     * https://web.dev/csp/
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCspMiddleware = class(TInjectableObject, IMiddleware)
    private
        fCspConfig: TCspConfig;
    public

        (*!---------------------------------------
         * constructor
         *----------------------------------------
         * @param cspConfig CSP configuration
         *----------------------------------------*)
        constructor create(const cspConfig: TCspConfig);

        (*!---------------------------------------
         * handle request and validate request
         *----------------------------------------
         * @param request request instance
         * @param response response instance
         * @param route arguments
         * @param next next middleware to execute
         * @return response
         *----------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const args : IRouteArgsReader;
            const next : IRequestHandler
        ) : IResponse;

    end;

implementation

    (*!---------------------------------------
     * add CSP response header value from
     * CSP configuration
     *----------------------------------------
     * @param configKey CSP configuration key
     * @param configValue CSP configuration value
     * @param headerValue previous header value
     * @return new header value
     *----------------------------------------*)
    function addCspConfig(const configKey, configValue, headerValue: string) : string;
    begin
        result := '';
        if length(configValue) > 0 then
        begin
            result := configKey + ' ' + configValue + '; ';
        end;
        result := headerValue + result;
    end;

    (*!---------------------------------------
     * add CSP response header value from
     * CSP configuration boolean value
     *----------------------------------------
     * @param configKey CSP configuration key
     * @param configValue CSP configuration value
     * @param headerValue previous header value
     * @return new header value
     *----------------------------------------*)
    function addCspConfigBool(const configKey: string; configValue: boolean; const headerValue: string) : string;
    begin
        result := '';
        if configValue then
        begin
            result := configKey + '; ';
        end;
        result := headerValue + result;
    end;

    (*!---------------------------------------
     * build CSP response header value from
     * CSP configuration
     *----------------------------------------
     * @param cspConfig CSP configuration
     *----------------------------------------*)
    function buildCspHeaderValue(const cspConfig: TCspConfig) : string;
    begin
        result := '';
        result := addCspConfig('default-src', cspConfig.defaultSrc, result);
        result := addCspConfig('base-uri', cspConfig.baseUri, result);
        result := addCspConfig('script-src', cspConfig.scriptSrc, result);
        result := addCspConfig('child-src', cspConfig.childSrc, result);
        result := addCspConfig('connect-src', cspConfig.connectSrc, result);
        result := addCspConfig('img-src', cspConfig.imgSrc, result);
        result := addCspConfig('font-src', cspConfig.fontSrc, result);
        result := addCspConfig('frame-ancestors', cspConfig.frameAncestors, result);
        result := addCspConfig('frame-src', cspConfig.frameSrc, result);
        result := addCspConfig('media-src', cspConfig.mediaSrc, result);
        result := addCspConfig('form-action', cspConfig.formAction, result);
        result := addCspConfig('style-src', cspConfig.styleSrc, result);
        result := addCspConfig('object-src', cspConfig.objectSrc, result);
        result := addCspConfig('plugin-types', cspConfig.pluginTypes, result);
        result := addCspConfig('report-uri', cspConfig.reportUri, result);
        result := addCspConfig('worker-src', cspConfig.workerSrc, result);
        result := addCspConfigBool('upgrade-insecure-requests', cspConfig.upgradeInsecureRequests, result);
    end;

    (*!---------------------------------------
     * constructor
     *----------------------------------------
     * @param cspConfig CSP configuration
     *----------------------------------------*)
    constructor TCspMiddleware.create(const cspConfig: TCspConfig);
    begin
        fCspConfig := cspConfig;
    end;

    (*!---------------------------------------
     * handle request
     *----------------------------------------
     * @param request request instance
     * @param response response instance
     * @param route arguments
     * @param next next middleware to execute
     * @return response
     *----------------------------------------*)
    function TCspMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        const next : IRequestHandler
    ) : IResponse;
    begin
        result := next.handleRequest(request, response, args);
        result.headers().setHeader('Content-Security-Policy', buildCspHeaderValue(fCspConfig));
    end;

end.
