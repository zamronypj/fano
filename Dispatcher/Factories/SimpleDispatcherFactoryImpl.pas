unit SimpleDispatcherFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl,
    RouteMatcherIntf;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TSimpleDispatcherFactory = class(TFactory, IDependencyFactory)
    private
        routeMatcher : IRouteMatcher;
    public
        constructor create (
            const routeMatcherInst : IRouteMatcher
        );
        destructor destroy(); override;
        function build() : IDependency; override;
    end;

implementation

uses
    SimpleDispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl;

    constructor TSimpleDispatcherFactory.create(
        const routeMatcherInst : IRouteMatcher
    );
    begin
        routeMatcher := routeMatcherInst;
    end;

    destructor TSimpleDispatcherFactory.destroy();
    begin
        inherited destroy();
        routeMatcher := nil;
    end;

    function TSimpleDispatcherFactory.build() : IDependency;
    begin
        result := TSimpleDispatcher.create(
            routeMatcher,
            TResponseFactory.create(),
            TRequestFactory.create()
        );
    end;

end.
