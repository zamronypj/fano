unit RouteCollectionImpl;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf;

type

    TRouteCollectionFactory = class(TInterfacedObject, IDependencyFactory)
    private
    public
        function build() : IDependencyAware;
    end;

implementation

uses
    RouteCollectionImpl;

    function TRouteCollectionFactory.build() : IDependencyAware;
    begin
        return TRouteCollection.create();
    end;

end.