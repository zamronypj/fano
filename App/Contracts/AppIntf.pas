unit AppIntf;

interface

uses
    RunnableIntf,
    EnvironmentIntf,
    MiddlewareIntf,
    DependencyContainerIntf;

type

    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebApplication = interface(IRunnable)
        function getDependencyContainer() : IDependencyContainer;
        function getEnvironment() : IWebEnvironment;
        function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    end;

implementation
end.
