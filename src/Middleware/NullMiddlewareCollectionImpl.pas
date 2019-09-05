{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullMiddlewareCollectionImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * IMiddlewareCollection implementation class that
     * does nothing
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNullMiddlewareCollection = class(TInjectableObject, IMiddlewareCollection)
    public
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
        function count() : integer;
        function get(const indx : integer) : IMiddleware;
        function merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    end;

implementation

    function TNullMiddlewareCollection.add(const middleware : IMiddleware) : IMiddlewareCollection;
    begin
        //intentionally do nothing
        result := self;
    end;

    function TNullMiddlewareCollection.count() : integer;
    begin
        //intentionally always empty
        result := 0;
    end;

    function TNullMiddlewareCollection.get(const indx : integer) : IMiddleware;
    begin
        //intentionally do nothing
        result := nil;
    end;

    function TNullMiddlewareCollection.merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    begin
        //intentionally do nothing
        result := self;
    end;

end.
