{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareCollectionImpl;

interface

{$MODE OBJFPC}

uses

    classes,
    DependencyIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * Basic class having capability to manage one or
     * more middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareCollection = class(TInjectableObject, IMiddlewareCollection)
    private
        middlewareList : TInterfaceList;
    public
        constructor create();
        destructor destroy(); override;
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
        function count() : integer;
        function get(const indx : integer) : IMiddleware;

        (*!------------------------------------------------
         * Merge current middleware collection with another
         * and return as new instance
         *-------------------------------------------------
         * @param middlewares another middleware collection
         * @return new merged middleware collection
         *-------------------------------------------------*)
        function merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    end;

implementation

    constructor TMiddlewareCollection.create();
    begin
        middlewareList := TInterfaceList.create();
    end;

    destructor TMiddlewareCollection.destroy();
    var i : integer;
        mw : IInterface;
    begin
        for i := middlewareList.count - 1 downto 0 do
        begin
            mw := middlewareList[i];
            mw := nil;
            middlewareList.delete(i);
        end;
        middlewareList.free();
        inherited destroy();
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

    (*!------------------------------------------------
     * Merge current middleware collection with another
     * and return as new instance
     *-------------------------------------------------
     * @param middlewares another middleware collection
     * @return new merged middleware collection
     *-------------------------------------------------*)
    function TMiddlewareCollection.merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    var newCollection : IMiddlewareCollection;
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
