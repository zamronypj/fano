unit MiddlewareCollectionFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    MiddlewareCollectionIntf,
    MiddlewareCollectionFactoryIntf,
    FactoryImpl;

type
    {*!
     basic class having capability to create
     middleware collection instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    *}
    TMiddlewareCollectionFactory = class(TFactory, IMiddlewareCollectionFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    MiddlewareCollectionImpl;

    function TMiddlewareCollectionFactory.build() : IDependency;
    begin
        result := TMiddlewareCollection.create();
    end;
end.
