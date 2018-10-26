{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit EnvironmentIntf;

interface

{$H+}

type

    {------------------------------------------------
     interface for any class having capability to retrieve
     CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    ICGIEnvironment = interface
        ['{48E2E809-1176-4863-B940-D1E05CF1355C}']

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
end.
