unit RouteCollectionFactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TRouteCollectionFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependencyAware; override;
    end;

implementation

uses
    RouteCollectionImpl,
    RouteListImpl;

    function TRouteCollectionFactory.build() : IDependencyAware;
    begin
        result := TRouteCollection.create(TRouteList.create());
    end;

end.
