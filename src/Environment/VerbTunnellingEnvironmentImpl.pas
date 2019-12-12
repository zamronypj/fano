{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit VerbTunnellingEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    EnvironmentIntf,
    EnvironmentEnumeratorIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * class having capability to retrieve
     * CGI environment variable and override HTTP method
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TVerbTunnellingEnvironment = class(TInjectableObject, ICGIEnvironment, ICGIEnvironmentEnumerator)
    private
        fEnvEnum : ICGIEnvironmentEnumerator;
        fEnv : ICGIEnvironment;

        function overrideMethod(
            const originalMethod : string;
            const methodOverrideHeader : string
        ) : string;
    public
        constructor create(
            const aEnv : ICGIEnvironment;
            const aEnvEnum : ICGIEnvironmentEnumerator
        );
        destructor destroy(); override;

        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const keyName : string) : string;

        {-----------------------------------------
         Retrieve GATEWAY_INTERFACE environment variable
        ------------------------------------------}
        function gatewayInterface() : string;

        {-----------------------------------------
         Retrieve REMOTE_ADDR environment variable
        ------------------------------------------}
        function remoteAddr() : string;

        {-----------------------------------------
         Retrieve REMOTE_PORT environment variable
        ------------------------------------------}
        function remotePort() : string;

        {-----------------------------------------
         Retrieve SERVER_ADDR environment variable
        ------------------------------------------}
        function serverAddr() : string;

        {-----------------------------------------
         Retrieve SERVER_PORT environment variable
        ------------------------------------------}
        function serverPort() : string;

        {-----------------------------------------
         Retrieve DOCUMENT_ROOT environment variable
        ------------------------------------------}
        function documentRoot() : string;

        {-----------------------------------------
         Retrieve REQUEST_METHOD environment variable
        ------------------------------------------}
        function requestMethod() : string;

        {-----------------------------------------
         Retrieve REQUEST_SCHEME environment variable
        ------------------------------------------}
        function requestScheme() : string;

        {-----------------------------------------
         Retrieve REQUEST_URI environment variable
        ------------------------------------------}
        function requestUri() : string;

        {-----------------------------------------
         Retrieve QUERY_STRING environment variable
        ------------------------------------------}
        function queryString() : string;

        {-----------------------------------------
         Retrieve SERVER_NAME environment variable
        ------------------------------------------}
        function serverName() : string;

        {-----------------------------------------
         Retrieve CONTENT_TYPE environment variable
        ------------------------------------------}
        function contentType() : string;

        {-----------------------------------------
         Retrieve CONTENT_LENGTH environment variable
        ------------------------------------------}
        function contentLength() : string;

        (*-----------------------------------------
         * Retrieve CONTENT_LENGTH environment variable
         * as integer value
         *------------------------------------------
         * @return content length as integer value
         *------------------------------------------*)
        function intContentLength() : integer;

        {-----------------------------------------
         Retrieve HTTP_HOST environment variable
        ------------------------------------------}
        function httpHost() : string;

        {-----------------------------------------
         Retrieve HTTP_USER_AGENT environment variable
        ------------------------------------------}
        function httpUserAgent() : string;

        {-----------------------------------------
         Retrieve HTTP_ACCEPT environment variable
        ------------------------------------------}
        function httpAccept() : string;

        {-----------------------------------------
         Retrieve HTTP_ACCEPT_LANGUAGE environment variable
        ------------------------------------------}
        function httpAcceptLanguage() : string;

        {-----------------------------------------
         Retrieve HTTP_COOKIE environment variable
        ------------------------------------------}
        function httpCookie() : string;

        (*!------------------------------------------------
         * get number of variables
         *-----------------------------------------------
         * @return number of variables
         *-----------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get key by index
         *-----------------------------------------------
         * @param index index to use
         * @return key name
         *-----------------------------------------------*)
        function getKey(const indx : integer) : shortstring;

        (*!------------------------------------------------
         * get value by index
         *-----------------------------------------------
         * @param index index to use
         * @return value name
         *-----------------------------------------------*)
        function getValue(const indx : integer) : string;

        function getEnumerator() : ICGIEnvironmentEnumerator;
    end;

implementation

uses

    sysutils,
    EInvalidMethodImpl;

    constructor TVerbTunnellingEnvironment.create(
        const aEnv : ICGIEnvironment;
        const aEnvEnum : ICGIEnvironmentEnumerator
    );
    begin
        fEnv := aEnv;
        fEnvEnum := aEnvEnum;
    end;

    destructor TVerbTunnellingEnvironment.destroy();
    begin
        fEnvEnum := nil;
        fEnv := nil;
        inherited destroy();
    end;

    function TVerbTunnellingEnvironment.overrideMethod(
        const originalMethod : string;
        const methodOverrideHeader : string
    ) : string;
    var allowed : boolean;
    begin
        result := originalMethod;
        if (originalMethod = 'POST') then
        begin
            if (methodOverrideHeader <> '') then
            begin
                //if we get here, header X-HTTP-Method-Override is set
                result := methodOverrideHeader;
            end;
        end;

        allowed := (result = 'GET') or
            (result = 'POST') or
            (result = 'PUT') or
            (result = 'DELETE') or
            (result = 'OPTIONS') or
            (result = 'PATCH') or
            (result = 'HEAD');

        if not allowed then
        begin
            //something is not right
            raise EInvalidMethod.createFmt(
                sErrInvalidMethod,
                [ methodOverrideHeader ]
            );
        end;
    end;

    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TVerbTunnellingEnvironment.env(const keyName : string) : string;
    begin
        if (keyName = 'REQUEST_METHOD') then
        begin
            result := overrideMethod(
                fEnv.requestMethod(),
                uppercase(fEnv.env('HTTP_X_HTTP_METHOD_OVERRIDE'))
            );
        end else
        begin
            result := fEnv.env(keyName);
        end;
    end;

    {-----------------------------------------
     Retrieve GATEWAY_INTERFACE environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.gatewayInterface() : string;
    begin
        result := fEnv.gatewayInterface();
    end;

    {-----------------------------------------
     Retrieve REMOTE_ADDR environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.remoteAddr() : string;
    begin
        result := fEnv.remoteAddr();
    end;

    {-----------------------------------------
     Retrieve REMOTE_PORT environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.remotePort() : string;
    begin
        result := fEnv.remotePort();
    end;

    {-----------------------------------------
     Retrieve SERVER_ADDR environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.serverAddr() : string;
    begin
        result := fEnv.serverAddr();
    end;

    {-----------------------------------------
     Retrieve SERVER_PORT environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.serverPort() : string;
    begin
        result := fEnv.serverPort();
    end;

    {-----------------------------------------
     Retrieve DOCUMENT_ROOT environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.documentRoot() : string;
    begin
        result := fEnv.documentRoot();
    end;

    {-----------------------------------------
     Retrieve REQUEST_METHOD environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.requestMethod() : string;
    begin
        result := env('REQUEST_METHOD');
    end;

    {-----------------------------------------
     Retrieve REQUEST_SCHEME environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.requestScheme() : string;
    begin
        result := fEnv.requestScheme();
    end;

    {-----------------------------------------
     Retrieve REQUEST_URI environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.requestUri() : string;
    begin
        result := fEnv.requestUri();
    end;

    {-----------------------------------------
     Retrieve QUERY_STRING environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.queryString() : string;
    begin
        result := fEnv.queryString();
    end;

    {-----------------------------------------
     Retrieve SERVER_NAME environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.serverName() : string;
    begin
        result := fEnv.serverName();
    end;

    {-----------------------------------------
     Retrieve CONTENT_TYPE environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.contentType() : string;
    begin
        result := fEnv.contentType();
    end;

    {-----------------------------------------
    Retrieve CONTENT_LENGTH environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.contentLength() : string;
    begin
        result := fEnv.contentType();
    end;

    (*-----------------------------------------
     * Retrieve CONTENT_LENGTH environment variable
     * as integer value
     *------------------------------------------
     * @return content length as integer value
     *------------------------------------------*)
    function TVerbTunnellingEnvironment.intContentLength() : integer;
    begin
        result := fEnv.intContentLength();
    end;

    {-----------------------------------------
     Retrieve HTTP_HOST environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.httpHost() : string;
    begin
        result := fEnv.httpHost();
    end;

    {-----------------------------------------
     Retrieve HTTP_USER_AGENT environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.httpUserAgent() : string;
    begin
        result := fEnv.httpUserAgent();
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.httpAccept() : string;
    begin
        result := fEnv.httpAccept();
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT_LANGUAGE environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.httpAcceptLanguage() : string;
    begin
        result := fEnv.httpAcceptLanguage();
    end;

    {-----------------------------------------
     Retrieve HTTP_COOKIE environment variable
    ------------------------------------------}
    function TVerbTunnellingEnvironment.httpCookie() : string;
    begin
        result := fEnv.httpCookie();
    end;

    (*!------------------------------------------------
     * get value by index
     *-----------------------------------------------
     * @param index index to use
     * @return key name
     *-----------------------------------------------*)
    function TVerbTunnellingEnvironment.getValue(const indx : integer) : string;
    begin
        result := fEnvEnum.getValue(indx);
    end;

    function TVerbTunnellingEnvironment.getEnumerator() : ICGIEnvironmentEnumerator;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * get number of variables
     *-----------------------------------------------
     * @return number of variables
     *-----------------------------------------------*)
    function TVerbTunnellingEnvironment.count() : integer;
    begin
        result := fEnvEnum.count();
    end;

    (*!------------------------------------------------
     * get key by index
     *-----------------------------------------------
     * @param index index to use
     * @return key name
     *-----------------------------------------------*)
    function TVerbTunnellingEnvironment.getKey(const indx : integer) : shortstring;
    begin
        result := fEnvEnum.getKey(indx);
    end;
end.
