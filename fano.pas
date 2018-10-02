unit fano;

interface

uses
   RunnableIntf,
   AppIntf,
   ConfigIntf,
   DispatcherIntf,
   EnvironmentIntf,
   RouterCollectionIntf,
   MiddlewareIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable, IRouterCollection)
    private
        config : IWebConfiguration;
        dispatcher : IDispatcher;
        environment : IWebEnvironment;
        routeCollection :IRouterCollection;
    public
        constructor create(
            const cfg : IWebConfiguration;
            const dispatcherInst : IDispatcher;
            const env : IWebEnvironment;
            const routesInst : IRouterCollection;
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
        function getEnvironment() : IWebEnvironment;

        //HTTP GET Verb handler
        function get(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP POST Verb handler
        function post(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP PUT Verb handler
        function put(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP PATCH Verb handler
        function patch(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP DELETE Verb handler
        function delete(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP HEAD Verb handler
        function head(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP OPTIONS Verb handler
        function options(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

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
    ) : IRouteCollection;
    begin
       self.routeCollection.get(routeName, routeHandler);
       result := self;
    end;

    //HTTP POST Verb handler
    function TFanoWebApplication.post(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.post(routeName, routeHandler);
       result := self;
    end;

    //HTTP PUT Verb handler
    function TFanoWebApplication.put(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.put(routeName, routeHandler);
       result := self;
    end;

    //HTTP PATCH Verb handler
    function TFanoWebApplication.patch(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.patch(routeName, routeHandler);
       result := self;
    end;

    //HTTP DELETE Verb handler
    function TFanoWebApplication.delete(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.delete(routeName, routeHandler);
       result := self;
    end;

    //HTTP HEAD Verb handler
    function TFanoWebApplication.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.head(routeName, routeHandler);
       result := self;
    end;

    //HTTP HEAD Verb handler
    function TFanoWebApplication.options(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       self.routeCollection.options(routeName, routeHandler);
       result := self;
    end;

    function addMiddleware(const middleware : IMiddleware) : IWebApplication;
    begin

    end;
end.
