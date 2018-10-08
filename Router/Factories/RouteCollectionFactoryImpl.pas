unit RouteCollectionFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TRouteCollectionFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    RouteCollectionImpl,
    RouteListImpl;

    function TRouteCollectionFactory.build() : IDependency;
    begin
        result := TRouteCollection.create(TRouteList.create());
    end;

end.
