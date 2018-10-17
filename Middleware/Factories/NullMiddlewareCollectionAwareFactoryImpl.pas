unit NullMiddlewareCollectionAwareFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {*!
     basic class having capability to create
     null middleware collection  aware instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TNullMiddlewareCollectionAwareFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    MiddlewareCollectionAwareImpl,
    NullMiddlewareCollectionImpl;

    function TNullMiddlewareCollectionAwareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TMiddlewareCollectionAware.create(
            TNullMiddlewareCollection.create(),
            TNullMiddlewareCollection.create()
        );
    end;
end.
