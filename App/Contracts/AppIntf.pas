unit AppIntf;

interface

uses
    RunnableIntf,
    EnvironmentIntf,
    MiddlewareCollectionAwareIntf;

type

    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebApplication = interface(IRunnable)
        ['{DE7521ED-D26F-4E97-9618-D745D38F0814}']
        function getEnvironment() : ICGIEnvironment;
        function getMiddlewares() : IMiddlewareCollectionAware;
    end;

implementation
end.
