unit MiddlewareCollectionImpl;

interface

uses
   MiddlewareIntf, MiddlewareCollectionIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     manage one or more middlewares
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TMiddlewareCollection = class(TInterfacedObject, IMiddlewareCollection)
    private
        list : TList
    public
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
    end;

implementation

    function TMiddlewareCollection.(const middleware : IMiddleware) : IMiddlewareCollection;
    begin

    end;
end.
