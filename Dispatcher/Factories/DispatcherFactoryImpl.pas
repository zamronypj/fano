unit DispatcherFactoryImpl;

interface

uses
    DispatcherFactoryIntf,
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcherFactory = class(TInterfacedObject, IDispatcherFactory, IDependencyFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware;
    end;

implementation

uses
    RouteMatcherIntf,
    DispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl;

    constructor TDispatcherFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TDispatcherFactory.destroy();
    begin
        inherited destroy();
        dependencyContainer := nil;
    end;

    function TDispatcherFactory.build() : IDependencyAware;
    begin
        result := TDispatcher.create(
            dependencyContainer.get('router') as IRouteMatcher,
            TResponseFactory.create(dependencyContainer),
            TRequestFactory.create(dependencyContainer)
        );
    end;

end.
