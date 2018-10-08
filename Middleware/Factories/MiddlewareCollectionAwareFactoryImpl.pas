unit MiddlewareCollectionAwareFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {*!
     basic class having capability to create
     middleware collection  awareinstance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TMiddlewareCollectionAwareFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    MiddlewareCollectionAwareImpl,
    MiddlewareCollectionImpl;

    function TMiddlewareCollectionAwareFactory.build() : IDependency;
    begin
        result := TMiddlewareCollectionAware.create(
            TMiddlewareCollection.create(),
            TMiddlewareCollection.create()
        );
    end;
end.
