unit RouteCollectionFactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf;

type

    TRouteCollectionFactory = class(TInterfacedObject, IDependencyFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware;
    end;

implementation

uses
    RouteCollectionImpl,
    RouteListImpl;

    constructor TRouteCollectionFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TRouteCollectionFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

    function TRouteCollectionFactory.build() : IDependencyAware;
    begin
        result := TRouteCollection.create(TRouteList.create());
    end;

end.
