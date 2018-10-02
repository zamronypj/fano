unit fano;

interface

uses
   RunnableIntf,
   AppIntf,
   ConfigIntf,
   DispatcherIntf,
   EnvironmentIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        config : IWebConfiguration;
        dispatcher : IDispatcher;
        environment : IWebEnvironment;
    public
        constructor create(
            const cfg : IWebConfiguration;
            const dispatcherInst : IDispatcher;
            const env : IWebEnvironment
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
        function getEnvironment() : IWebEnvironment;
    end;

implementation

uses
   ResponseIntf;

    constructor TFanoWebApplication.create(
        const cfg : IWebConfiguration;
        const dispatcherInst : IDispatcher;
        const env : IWebEnvironment
    );
    begin
       self.config := cfg;
       self.dispatcher := dispatcherInst;
       self.environment := env;
    end;

    destructor TFanoWebApplication.destroy();
    begin
       self.config := nil;
       self.dispatcher := nil;
    end;

    function TFanoWebApplication.run() : IRunnable;
    var response : IResponse;
    begin
       response := dispatcher.handleRequest(self.getEnvironment());
       response.write();
       result := self;
    end;

    function TFanoWebApplication.getEnvironment() : IWebEnvironment;
    begin
       result := self.environment;
    end;
end.
