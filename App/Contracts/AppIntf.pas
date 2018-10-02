unit AppIntf;

interface

uses RunnableIntf, ConfigIntf, EnvironmentIntf;

type
    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebApplication = interface(IRunnable)
       function getEnvironment(const config: IWebConfiguration) : IWebEnvironment;
    end;

implementation
end.
