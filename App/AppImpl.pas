unit AppImpl;

interface

uses
   RunnableIntf,
   DependencyContainerIntf,
   AppIntf,
   ConfigIntf,
   DispatcherIntf,
   EnvironmentIntf,
   RouteCollectionIntf,
   RouteHandlerIntf,
   MiddlewareIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable, IRouteCollection)
    private
        config : IWebConfiguration;
        dispatcher : IDispatcher;
        environment : IWebEnvironment;
        routeCollection :IRouteCollection;
        dependencyContainer : IDependencyContainer;
    public
        constructor create(
            const cfg : IWebConfiguration;
            const dispatcherInst : IDispatcher;
            const env : IWebEnvironment;
            const routesInst : IRouteCollection;
            const dc : IDependencyContainer
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
        function getDependencyContainer() : IDependencyContainer;
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
        const routesInst : IRouteCollection;
        const dc : IDependencyContainer
    );
    begin
       config := cfg;
       dispatcher := dispatcherInst;
       environment := env;
       routeCollection := routesInst;
       dependencyContainer := dc;
    end;

    destructor TFanoWebApplication.destroy();
    begin
       config := nil;
       dispatcher := nil;
       environment := nil;
       routeCollection := nil;
       dependencyContainer := nil;
    end;

    function TFanoWebApplication.run() : IRunnable;
    var response : IResponse;
    begin
       response := dispatcher.dispatchRequest(getEnvironment());
       response.write();
       result := self;
    end;

    function TFanoWebApplication.getEnvironment() : IWebEnvironment;
    begin
       result := environment;
    end;

    function TFanoWebApplication.getDependencyContainer() : IDependencyContainer;
    begin
       result := dependencyContainer;
    end;

    //HTTP GET Verb handler
    function TFanoWebApplication.get(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.get(routeName, routeHandler);
       result := self;
    end;

    //HTTP POST Verb handler
    function TFanoWebApplication.post(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.post(routeName, routeHandler);
       result := self;
    end;

    //HTTP PUT Verb handler
    function TFanoWebApplication.put(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.put(routeName, routeHandler);
       result := self;
    end;

    //HTTP PATCH Verb handler
    function TFanoWebApplication.patch(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.patch(routeName, routeHandler);
       result := self;
    end;

    //HTTP DELETE Verb handler
    function TFanoWebApplication.delete(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.delete(routeName, routeHandler);
       result := self;
    end;

    //HTTP HEAD Verb handler
    function TFanoWebApplication.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.head(routeName, routeHandler);
       result := self;
    end;

    //HTTP HEAD Verb handler
    function TFanoWebApplication.options(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    begin
       routeCollection.options(routeName, routeHandler);
       result := self;
    end;

    function TFanoWebApplication.addMiddleware(const middleware : IMiddleware) : IWebApplication;
    begin
        //TODO:add middleware
        result := self;
    end;
end.
