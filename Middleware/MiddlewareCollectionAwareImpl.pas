unit MiddlewareCollectionAwareImpl;

interface

uses
    DependencyIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    MiddlewareCollectionAwareIntf;

type
    {------------------------------------------------
     class that can maintain before and after middlewares
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TMiddlewareCollectionAware = class(TInterfacedObject, IDependency, IMiddlewareCollectionAware)
    private
        beforeMiddlewareList : IMiddlewareCollection;
        afterMiddlewareList : IMiddlewareCollection;
    public
        constructor create(
            const beforeMiddlewares : IMiddlewareCollection;
            const afterMiddlewares : IMiddlewareCollection
        );
        destructor destroy(); override;
        function addBeforeMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function addAfterMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function getBeforeMiddlewares() : IMiddlewareCollection;
        function getAfterMiddlewares() : IMiddlewareCollection;
    end;

implementation

    constructor TMiddlewareCollectionAware.create(
        const beforeMiddlewares : IMiddlewareCollection;
        const afterMiddlewares : IMiddlewareCollection
    );
    begin
        beforeMiddlewareList := beforeMiddlewares;
        afterMiddlewareList := afterMiddlewares;
    end;

    destructor TMiddlewareCollectionAware.destroy();
    begin
        inherited destroy();
        beforeMiddlewareList := nil;
        afterMiddlewareList := nil;
    end;

    function TMiddlewareCollectionAware.addBeforeMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        beforeMiddlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollectionAware.addAfterMiddleware(const middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        afterMiddlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollectionAware.getBeforeMiddlewares() : IMiddlewareCollection;
    begin
        result := beforeMiddlewareList;
    end;

    function TMiddlewareCollectionAware.getAfterMiddlewares() : IMiddlewareCollection;
    begin
        result := afterMiddlewareList;
    end;

end.
