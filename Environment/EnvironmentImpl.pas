unit EnvironmentImpl;

interface
{$H+}

uses
    DependencyAwareIntf,
    EnvironmentIntf;

type
    {------------------------------------------------
     interface for any class having capability to retrieve
     CGI environment variable

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TWebEnvironment = class(TInterfacedObject, IWebEnvironment, IDependencyAware)
    private
    public
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
    end;

implementation

uses
    dos;

    {-----------------------------------------
     Retrieve GATEWAY_INTERFACE environment variable
    ------------------------------------------}
    function TWebEnvironment.gatewayInterface() : string;
    begin
        result := getenv('GATEWAY_INTERFACE');
    end;

    {-----------------------------------------
     Retrieve REMOTE_ADDR environment variable
    ------------------------------------------}
    function TWebEnvironment.remoteAddr() : string;
    begin
        result := getenv('REMOTE_ADDR');
    end;

    {-----------------------------------------
     Retrieve REMOTE_PORT environment variable
    ------------------------------------------}
    function TWebEnvironment.remotePort() : string;
    begin
        result := getenv('REMOTE_PORT');
    end;

    {-----------------------------------------
     Retrieve SERVER_ADDR environment variable
    ------------------------------------------}
    function TWebEnvironment.serverAddr() : string;
    begin
        result := getenv('SERVER_ADDR');
    end;

    {-----------------------------------------
     Retrieve SERVER_PORT environment variable
    ------------------------------------------}
    function TWebEnvironment.serverPort() : string;
    begin
        result := getenv('SERVER_PORT');
    end;

    {-----------------------------------------
     Retrieve DOCUMENT_ROOT environment variable
    ------------------------------------------}
    function TWebEnvironment.documentRoot() : string;
    begin
        result := getenv('DOCUMENT_ROOT');
    end;

    {-----------------------------------------
     Retrieve REQUEST_METHOD environment variable
    ------------------------------------------}
    function TWebEnvironment.requestMethod() : string;
    begin
        result := getenv('REQUEST_METHOD');
    end;

    {-----------------------------------------
     Retrieve REQUEST_SCHEME environment variable
    ------------------------------------------}
    function TWebEnvironment.requestScheme() : string;
    begin
        result := getenv('REQUEST_SCHEME');
    end;

    {-----------------------------------------
     Retrieve REQUEST_URI environment variable
    ------------------------------------------}
    function TWebEnvironment.requestUri() : string;
    begin
        result := getenv('REQUEST_URI');
    end;

    {-----------------------------------------
     Retrieve QUERY_STRING environment variable
    ------------------------------------------}
    function TWebEnvironment.queryString() : string;
    begin
        result := getenv('QUERY_STRING');
    end;

    {-----------------------------------------
     Retrieve SERVER_NAME environment variable
    ------------------------------------------}
    function TWebEnvironment.serverName() : string;
    begin
        result := getenv('SERVER_NAME');
    end;

    {-----------------------------------------
     Retrieve CONTENT_TYPE environment variable
    ------------------------------------------}
    function TWebEnvironment.contentType() : string;
    begin
        result := getenv('CONTENT_TYPE');
    end;

    {-----------------------------------------
     Retrieve HTTP_HOST environment variable
    ------------------------------------------}
    function TWebEnvironment.httpHost() : string;
    begin
        result := getenv('HTTP_HOST');
    end;

    {-----------------------------------------
     Retrieve HTTP_USER_AGENT environment variable
    ------------------------------------------}
    function TWebEnvironment.httpUserAgent() : string;
    begin
        result := getenv('HTTP_USER_AGENT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT environment variable
    ------------------------------------------}
    function TWebEnvironment.httpAccept() : string;
    begin
        result := getenv('HTTP_ACCEPT');
    end;

    {-----------------------------------------
     Retrieve HTTP_ACCEPT_LANGUAGE environment variable
    ------------------------------------------}
    function TWebEnvironment.httpAcceptLanguage() : string;
    begin
        result := getenv('HTTP_ACCEPT_LANGUAGE');
    end;
end.
