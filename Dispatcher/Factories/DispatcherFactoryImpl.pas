unit DispatcherFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RouteMatcherIntf,
    MiddlewareCollectionAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcherFactory = class(TFactory, IDependencyFactory)
    private
        appMiddlewares : IMiddlewareCollectionAware;
        routeMatcher : IRouteMatcher;
    public
        constructor create (
            const appMiddlewaresInst : IMiddlewareCollectionAware;
            const routeMatcherInst : IRouteMatcher
        );
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    DispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl,
    MiddlewareChainFactoryImpl;

    constructor TDispatcherFactory.create(
        const appMiddlewaresInst : IMiddlewareCollectionAware;
        const routeMatcherInst : IRouteMatcher
    );
    begin
        appMiddlewares := appMiddlewaresInst;
        routeMatcher := routeMatcherInst;
    end;

    destructor TDispatcherFactory.destroy();
    begin
        inherited destroy();
        appMiddlewares := nil;
        routeMatcher := nil;
    end;

    function TDispatcherFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TDispatcher.create(
            appMiddlewares.getBeforeMiddlewares(),
            appMiddlewares.getAfterMiddlewares(),
            TMiddlewareChainFactory.create(),
            routeMatcher,
            TResponseFactory.create(),
            TRequestFactory.create()
        );
    end;

end.
