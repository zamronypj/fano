unit MiddlewareCollectionAwareFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {*!
     basic class having capability to create
     middleware collection  awareinstance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TMiddlewareCollectionAwareFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    MiddlewareCollectionAwareImpl,
    MiddlewareCollectionImpl;

    function TMiddlewareCollectionAwareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TMiddlewareCollectionAware.create(
            TMiddlewareCollection.create(),
            TMiddlewareCollection.create()
        );
    end;
end.
