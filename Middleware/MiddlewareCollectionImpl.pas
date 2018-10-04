unit MiddlewareCollectionImpl;

interface

uses
    contnrs,
    MiddlewareIntf,
    MiddlewareCollectionIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     manage one or more middlewares
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TMiddlewareCollection = class(TInterfacedObject, IMiddlewareCollection)
    private
        middlewareList : TFPList;
    public
        constructor create();
        destructor destroy(); override;
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
        function count() : integer;
        function get(const indx : integer) : IMiddleware;
    end;

implementation

    constructor TMiddlewareCollection.create();
    begin
        middlewareList := TFPList.Create();
    end;

    destructor TMiddlewareCollection.destroy();
    var middleware : IMiddleware;
        i:integer;
    begin
        for i := middlewareList.count - 1 downto 0 do
        begin
            middleware := middlewareList.items[i];
            middleware := nil;
            middlewareList.delete(i);
        end;
        middlewareList.free();
    end;

    function TMiddlewareCollection.add(const middleware : IMiddleware) : IMiddlewareCollection;
    begin
        middlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollection.count() : integer;
    begin
        result := middlewareList.count;
    end;

    function TMiddlewareCollection.get(const indx : integer) : IMiddleware;
      var middleware : IMiddleware;
    begin
        middleware := middlewareList.items[i];
        result := middleware;
    end;

end.
