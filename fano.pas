unit fano;

interface

uses
   RunnableIntf,
   AppIntf,
   ConfigIntf,
   DispatcherIntf,
   EnvironmentIntf,
   HttpVerbIntf,
   MiddlewareIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable, IHttpVerb)
    private
        config : IWebConfiguration;
        dispatcher : IDispatcher;
        environment : IWebEnvironment;
        verb :IHttpVerb;
    public
        constructor create(
            const cfg : IWebConfiguration;
            const dispatcherInst : IDispatcher;
            const env : IWebEnvironment;
            const verbInst ; IHttpVerb;
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
        function getEnvironment() : IWebEnvironment;

        //HTTP GET Verb handler
        function get(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP POST Verb handler
        function post(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP PUT Verb handler
        function put(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP DELETE Verb handler
        function delete(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP HEAD Verb handler
        function head(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    end;

implementation

uses
   ResponseIntf;

    constructor TFanoWebApplication.create(
        const cfg : IWebConfiguration;
        const dispatcherInst : IDispatcher;
        const env : IWebEnvironment;
        const verbInst : IHttpVerb
    );
    begin
       self.config := cfg;
       self.dispatcher := dispatcherInst;
       self.environment := env;
       self.verb := verbInst;
    end;

    destructor TFanoWebApplication.destroy();
    begin
       self.config := nil;
       self.dispatcher := nil;
       self.environment := nil;
       self.verb := nil;
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

    //HTTP GET Verb handler
    function TFanoWebApplication.get(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IHttpVerb;
    begin

    end;

    //HTTP POST Verb handler
    function TFanoWebApplication.post(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IHttpVerb;
    begin

    end;

    //HTTP PUT Verb handler
    function TFanoWebApplication.put(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IHttpVerb;
    begin

    end;

    //HTTP DELETE Verb handler
    function TFanoWebApplication.delete(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IHttpVerb;
    begin

    end;

    //HTTP HEAD Verb handler
    function TFanoWebApplication.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IHttpVerb;
    begin

    end;

    function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    begin

    end;
end.
