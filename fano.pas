unit fano;

interface

uses AppIntf, ConfigIntf, DispatcherIntf;

type

    TFanoApplication = class(TInterfacedObject, IWebApplication)
    private
        config : IWebConfiguration;
        dispatcher : IDispatcher;
    public
        constructor create(
            const config : IWebConfiguration,
            const dispatcher : IDispatcher
        ); virtual;
        destructor destroy(); override;
        function run() : IWebApplication;
    end;

implementation
    constructor TFanoWebApplication.create(const config : IWebConfiguration, const dispatcher : IDispatcher);
    begin
       self.config := config;
       self.dispatcher := dispatcher;
    end;

    destructor TFanoWebApplication.destroy();
    begin
       self.config := nil;
       self.dispatcher := nil;
    end;

    function TFanoApplication.run() : IWebApplication;
    var response : IResponse;
    begin
       response := dispatcher.handleRequest(self.getEnvironment(self.config));
       response.write();
       result := self;
    end;
end.
