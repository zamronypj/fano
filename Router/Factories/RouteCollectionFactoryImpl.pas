unit RouteCollectionFactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf;

type

    TRouteCollectionFactory = class(TInterfacedObject, IDependencyFactory)
    public
        function build() : IDependencyAware;
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
