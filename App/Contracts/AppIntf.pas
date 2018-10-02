unit AppIntf;

interface

uses RunnableIntf, EnvironmentIntf, RouteHandlerIntf, HttpVerbIntf;

type
    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebApplication = interface(IRunnable, IHttpVerb)
        function getEnvironment() : IWebEnvironment;
        function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    end;

implementation
end.
