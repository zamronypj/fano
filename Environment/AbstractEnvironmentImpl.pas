{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    EnvironmentIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * base class for any class having capability to retrieve
     * CGI environment variable
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TAbstractCGIEnvironment = class(TInjectableObject, ICGIEnvironment)
    public
        (*!-----------------------------------------
         * Retrieve an environment variable
         *------------------------------------------
         * @param key name of variable
         * @return variable value
         *------------------------------------------*)
        function env(const key : string) : string; virtual; abstract;

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
    end;

implementation

uses

    sysutils,
    EInvalidRequestImpl;

resourcestring

    sErrInvalidContentLength = 'Invalid content length';

    {-----------------------------------------
     Retrieve GATEWAY_INTERFACE environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.gatewayInterface() : string;
    begin
        result := env('GATEWAY_INTERFACE');
    end;

    {-----------------------------------------
     Retrieve REMOTE_ADDR environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.remoteAddr() : string;
    begin
        result := env('REMOTE_ADDR');
    end;

    {-----------------------------------------
     Retrieve REMOTE_PORT environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.remotePort() : string;
    begin
        result := env('REMOTE_PORT');
    end;

    {-----------------------------------------
     Retrieve SERVER_ADDR environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.serverAddr() : string;
    begin
        result := env('SERVER_ADDR');
    end;

    {-----------------------------------------
     Retrieve SERVER_PORT environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.serverPort() : string;
    begin
        result := env('SERVER_PORT');
    end;

    {-----------------------------------------
     Retrieve DOCUMENT_ROOT environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.documentRoot() : string;
    begin
        result := env('DOCUMENT_ROOT');
    end;

    {-----------------------------------------
     Retrieve REQUEST_METHOD environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.requestMethod() : string;
    begin
        result := env('REQUEST_METHOD');
    end;

    {-----------------------------------------
     Retrieve REQUEST_SCHEME environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.requestScheme() : string;
    begin
        result := env('REQUEST_SCHEME');
    end;

    {-----------------------------------------
     Retrieve REQUEST_URI environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.requestUri() : string;
    begin
        result := env('REQUEST_URI');
    end;

    {-----------------------------------------
     Retrieve QUERY_STRING environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.queryString() : string;
    begin
        result := env('QUERY_STRING');
    end;

    {-----------------------------------------
     Retrieve SERVER_NAME environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.serverName() : string;
    begin
        result := env('SERVER_NAME');
    end;

    {-----------------------------------------
     Retrieve CONTENT_TYPE environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.contentType() : string;
    begin
        result := env('CONTENT_TYPE');
    end;

    {-----------------------------------------
    Retrieve CONTENT_LENGTH environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.contentLength() : string;
    begin
        result := env('CONTENT_LENGTH');
    end;

    (*-----------------------------------------
     * Retrieve CONTENT_LENGTH environment variable
     * as integer value
     *------------------------------------------
     * @return content length as integer value
     *------------------------------------------*)
    function TAbstractCGIEnvironment.intContentLength() : integer;
    begin
        try
            result := strToInt(contentLength());
        except
            on e:EConvertError do
            begin
                raise EInvalidRequest.create(sErrInvalidContentLength);
            end;
        end;
    end;

    {-----------------------------------------
     Retrieve HTTP_HOST environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.httpHost() : string;
    begin
        result := env('HTTP_HOST');
    end;

    {-----------------------------------------
     Retrieve HTTP_USER_AGENT environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.httpUserAgent() : string;
    begin
        result := env('HTTP_USER_AGENT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.httpAccept() : string;
    begin
        result := env('HTTP_ACCEPT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT_LANGUAGE environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.httpAcceptLanguage() : string;
    begin
        result := env('HTTP_ACCEPT_LANGUAGE');
    end;

    {-----------------------------------------
     Retrieve HTTP_COOKIE environment variable
    ------------------------------------------}
    function TAbstractCGIEnvironment.httpCookie() : string;
    begin
        result := env('HTTP_COOKIE');
    end;
end.
