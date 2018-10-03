unit EnvironmentImpl;

interface

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
         Retrieve REMOTE_ADDR environment variable
        ------------------------------------------}
        function remoteAddr() : string;

        {-----------------------------------------
         Retrieve REMOTE_PORT environment variable
        ------------------------------------------}
        function remotePort() : string;

        {-----------------------------------------
         Retrieve DOCUMENT_ROOT environment variable
        ------------------------------------------}
        function documentRoot() : string;

        {-----------------------------------------
         Retrieve REQUEST_METHOD environment variable
        ------------------------------------------}
        function requestMethod() : string;

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
    end;

implementation

uses
    dos;

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

end.
