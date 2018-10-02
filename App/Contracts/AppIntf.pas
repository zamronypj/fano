unit AppIntf;

interface

uses RunnableIntf, EnvironmentIntf, RouteCollectionIntf;

type
    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebApplication = interface(IRunnable, IRouteCollection)
        function getEnvironment() : IWebEnvironment;
        function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    end;

implementation
end.
