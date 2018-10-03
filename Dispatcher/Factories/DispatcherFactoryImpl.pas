unit DispatcherFactoryImpl;

interface

uses
    DispatcherFactoryIntf,
    DependencyAwareIntf,
    DependencyContainerIntf;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcherFactory = class(TInterfacedObject, IDispatcherFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware;
    end;

implementation

uses
    RouteFinderIntf,
    DispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl;

    constructor TDispatcherFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TDispatcherFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

    function TDispatcherFactory.build() : IDependencyAware;
    begin
        result := TDispatcher.create(
            dependencyContainer.get('router') as IRouteFinder,
            TResponseFactory.create(dependencyContainer),
            TRequestFactory.create(dependencyContainer)
        );
    end;

end.
