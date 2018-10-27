{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareCollectionImpl;

interface

{$MODE OBJFPC}

uses

    classes,
    DependencyIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf;

type

    (*!------------------------------------------------
     * Basic class having capability to manage one or
     * more middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareCollection = class(TInterfacedObject, IMiddlewareCollection, IDependency)
    private
        middlewareList : TInterfaceList;
    public
        constructor create();
        destructor destroy(); override;
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
        function count() : integer;
        function get(const indx : integer) : IMiddleware;
        function merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    end;

implementation

    constructor TMiddlewareCollection.create();
    begin
        middlewareList := TInterfaceList.Create();
    end;

    destructor TMiddlewareCollection.destroy();
    var i : integer;
        amiddleware : IMiddleware;
    begin
        inherited destroy();
        for i := middlewareList.count - 1 downto 0 do
        begin
            amiddleware := get(i);
            amiddleware := nil;
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
    begin
        result := middlewareList.items[indx] as IMiddleware;
    end;

    function TMiddlewareCollection.merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    var newCollection : TMiddlewareCollection;
        i, len : integer;
    begin
        newCollection := TMiddlewareCollection.create();
        len := count();
        for i:= 0 to len-1 do
        begin
            newCollection.add(get(i));
        end;
        len := middlewares.count();
        for i:= 0 to len-1 do
        begin
            newCollection.add(middlewares.get(i));
        end;
        result := newCollection;
    end;

end.
