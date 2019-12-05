{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit WithMethodOverrideEnvironmentImpl;

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
    TWithMethodOverrideEnvironment = class(TInjectableObject, ICGIEnvironment, ICGIEnvironmentEnumerator)
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

    constructor TWithMethodOverrideEnvironment.create(
        const aEnv : ICGIEnvironment;
        const aEnvEnum : ICGIEnvironmentEnumerator
    );
    begin
        fEnv := aEnv;
        fEnvEnum := aEnvEnum;
    end;

    destructor TWithMethodOverrideEnvironment.destroy();
    begin
        fEnvEnum := nil;
        fEnv := nil;
        inherited destroy();
    end;

    function TWithMethodOverrideEnvironment.overrideMethod(
        const originalMethod : string;
        const methodOverrideHeader : string
    ) : string;
    begin
        result := originalMethod;
        if (originalMethod = 'POST') then
        begin
            if (methodOverrideHeader <> '') then
            begin
                //if we get here, header X-HTTP-Method-Override is set
                if (methodOverrideHeader = 'GET') or
                    (methodOverrideHeader = 'POST') or
                    (methodOverrideHeader = 'PUT') or
                    (methodOverrideHeader = 'DELETE') or
                    (methodOverrideHeader = 'OPTIONS') or
                    (methodOverrideHeader = 'PATCH') or
                    (methodOverrideHeader = 'HEAD') then
                begin
                    //override actual method
                    result := methodOverrideHeader;
                end else
                begin
                    //something is not right
                    raise EInvalidMethod.createFmt(
                        sErrInvalidMethod,
                        [ methodOverrideHeader ]
                    );
                end;
            end;
        end;
    end;

    (*!-----------------------------------------
     * Retrieve an environment variable
     *------------------------------------------
     * @param key name of variable
     * @return variable value
     *------------------------------------------*)
    function TWithMethodOverrideEnvironment.env(const keyName : string) : string;
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
    function TWithMethodOverrideEnvironment.gatewayInterface() : string;
    begin
        result := fEnv.gatewayInterface();
    end;

    {-----------------------------------------
     Retrieve REMOTE_ADDR environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.remoteAddr() : string;
    begin
        result := fEnv.remoteAddr();
    end;

    {-----------------------------------------
     Retrieve REMOTE_PORT environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.remotePort() : string;
    begin
        result := fEnv.remotePort();
    end;

    {-----------------------------------------
     Retrieve SERVER_ADDR environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.serverAddr() : string;
    begin
        result := fEnv.serverAddr();
    end;

    {-----------------------------------------
     Retrieve SERVER_PORT environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.serverPort() : string;
    begin
        result := fEnv.serverPort();
    end;

    {-----------------------------------------
     Retrieve DOCUMENT_ROOT environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.documentRoot() : string;
    begin
        result := fEnv.documentRoot();
    end;

    {-----------------------------------------
     Retrieve REQUEST_METHOD environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.requestMethod() : string;
    begin
        result := overrideMethod(
            fEnv.requestMethod(),
            uppercase(fEnv.env('HTTP_X_HTTP_METHOD_OVERRIDE'))
        );
    end;

    {-----------------------------------------
     Retrieve REQUEST_SCHEME environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.requestScheme() : string;
    begin
        result := fEnv.requestScheme();
    end;

    {-----------------------------------------
     Retrieve REQUEST_URI environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.requestUri() : string;
    begin
        result := fEnv.requestUri();
    end;

    {-----------------------------------------
     Retrieve QUERY_STRING environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.queryString() : string;
    begin
        result := fEnv.queryString();
    end;

    {-----------------------------------------
     Retrieve SERVER_NAME environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.serverName() : string;
    begin
        result := fEnv.serverName();
    end;

    {-----------------------------------------
     Retrieve CONTENT_TYPE environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.contentType() : string;
    begin
        result := fEnv.contentType();
    end;

    {-----------------------------------------
    Retrieve CONTENT_LENGTH environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.contentLength() : string;
    begin
        result := fEnv.contentType();
    end;

    (*-----------------------------------------
     * Retrieve CONTENT_LENGTH environment variable
     * as integer value
     *------------------------------------------
     * @return content length as integer value
     *------------------------------------------*)
    function TWithMethodOverrideEnvironment.intContentLength() : integer;
    begin
        result := fEnv.intContentLength();
    end;

    {-----------------------------------------
     Retrieve HTTP_HOST environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.httpHost() : string;
    begin
        result := fEnv.httpHost();
    end;

    {-----------------------------------------
     Retrieve HTTP_USER_AGENT environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.httpUserAgent() : string;
    begin
        result := fEnv.httpUserAgent();
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.httpAccept() : string;
    begin
        result := fEnv.httpAccept();
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT_LANGUAGE environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.httpAcceptLanguage() : string;
    begin
        result := fEnv.httpAcceptLanguage();
    end;

    {-----------------------------------------
     Retrieve HTTP_COOKIE environment variable
    ------------------------------------------}
    function TWithMethodOverrideEnvironment.httpCookie() : string;
    begin
        result := fEnv.httpCookie();
    end;

    (*!------------------------------------------------
     * get value by index
     *-----------------------------------------------
     * @param index index to use
     * @return key name
     *-----------------------------------------------*)
    function TWithMethodOverrideEnvironment.getValue(const indx : integer) : string;
    begin
        result := fEnvEnum.getValue(indx);
    end;

    function TWithMethodOverrideEnvironment.getEnumerator() : ICGIEnvironmentEnumerator;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * get number of variables
     *-----------------------------------------------
     * @return number of variables
     *-----------------------------------------------*)
    function TWithMethodOverrideEnvironment.count() : integer;
    begin
        result := fEnvEnum.count();
    end;

    (*!------------------------------------------------
     * get key by index
     *-----------------------------------------------
     * @param index index to use
     * @return key name
     *-----------------------------------------------*)
    function TWithMethodOverrideEnvironment.getKey(const indx : integer) : shortstring;
    begin
        result := fEnvEnum.getKey(indx);
    end;
end.
