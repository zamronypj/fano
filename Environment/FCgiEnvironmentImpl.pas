{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiEnvironmentImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    EnvironmentIntf;

type

    (*!------------------------------------------------
     * basic having capability to retrieve
     * CGI environment variable from FastCGI protocol
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TFCGIEnvironment = class(TInterfacedObject, ICGIEnvironment, IDependency)
    private

    public
        {-----------------------------------------
         Retrieve an environment variable
        ------------------------------------------}
        function env(const key : string) : string;

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
    dos;

    {-----------------------------------------
     Retrieve an environment variable
    ------------------------------------------}
    function TCGIEnvironment.env(const key : string) : string;
    begin
        result := getenv(key);
    end;

    {-----------------------------------------
     Retrieve GATEWAY_INTERFACE environment variable
    ------------------------------------------}
    function TCGIEnvironment.gatewayInterface() : string;
    begin
        result := getenv('GATEWAY_INTERFACE');
    end;

    {-----------------------------------------
     Retrieve REMOTE_ADDR environment variable
    ------------------------------------------}
    function TCGIEnvironment.remoteAddr() : string;
    begin
        result := getenv('REMOTE_ADDR');
    end;

    {-----------------------------------------
     Retrieve REMOTE_PORT environment variable
    ------------------------------------------}
    function TCGIEnvironment.remotePort() : string;
    begin
        result := getenv('REMOTE_PORT');
    end;

    {-----------------------------------------
     Retrieve SERVER_ADDR environment variable
    ------------------------------------------}
    function TCGIEnvironment.serverAddr() : string;
    begin
        result := getenv('SERVER_ADDR');
    end;

    {-----------------------------------------
     Retrieve SERVER_PORT environment variable
    ------------------------------------------}
    function TCGIEnvironment.serverPort() : string;
    begin
        result := getenv('SERVER_PORT');
    end;

    {-----------------------------------------
     Retrieve DOCUMENT_ROOT environment variable
    ------------------------------------------}
    function TCGIEnvironment.documentRoot() : string;
    begin
        result := getenv('DOCUMENT_ROOT');
    end;

    {-----------------------------------------
     Retrieve REQUEST_METHOD environment variable
    ------------------------------------------}
    function TCGIEnvironment.requestMethod() : string;
    begin
        result := getenv('REQUEST_METHOD');
    end;

    {-----------------------------------------
     Retrieve REQUEST_SCHEME environment variable
    ------------------------------------------}
    function TCGIEnvironment.requestScheme() : string;
    begin
        result := getenv('REQUEST_SCHEME');
    end;

    {-----------------------------------------
     Retrieve REQUEST_URI environment variable
    ------------------------------------------}
    function TCGIEnvironment.requestUri() : string;
    begin
        result := getenv('REQUEST_URI');
    end;

    {-----------------------------------------
     Retrieve QUERY_STRING environment variable
    ------------------------------------------}
    function TCGIEnvironment.queryString() : string;
    begin
        result := getenv('QUERY_STRING');
    end;

    {-----------------------------------------
     Retrieve SERVER_NAME environment variable
    ------------------------------------------}
    function TCGIEnvironment.serverName() : string;
    begin
        result := getenv('SERVER_NAME');
    end;

    {-----------------------------------------
     Retrieve CONTENT_TYPE environment variable
    ------------------------------------------}
    function TCGIEnvironment.contentType() : string;
    begin
        result := getenv('CONTENT_TYPE');
    end;

    {-----------------------------------------
    Retrieve CONTENT_LENGTH environment variable
    ------------------------------------------}
    function TCGIEnvironment.contentLength() : string;
    begin
        result := getenv('CONTENT_LENGTH');
    end;

    {-----------------------------------------
     Retrieve HTTP_HOST environment variable
    ------------------------------------------}
    function TCGIEnvironment.httpHost() : string;
    begin
        result := getenv('HTTP_HOST');
    end;

    {-----------------------------------------
     Retrieve HTTP_USER_AGENT environment variable
    ------------------------------------------}
    function TCGIEnvironment.httpUserAgent() : string;
    begin
        result := getenv('HTTP_USER_AGENT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT environment variable
    ------------------------------------------}
    function TCGIEnvironment.httpAccept() : string;
    begin
        result := getenv('HTTP_ACCEPT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT_LANGUAGE environment variable
    ------------------------------------------}
    function TCGIEnvironment.httpAcceptLanguage() : string;
    begin
        result := getenv('HTTP_ACCEPT_LANGUAGE');
    end;

    {-----------------------------------------
     Retrieve HTTP_COOKIE environment variable
    ------------------------------------------}
    function TCGIEnvironment.httpCookie() : string;
    begin
        result := getenv('HTTP_COOKIE');
    end;
end.
