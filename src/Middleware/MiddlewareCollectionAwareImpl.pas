{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareCollectionAwareImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    MiddlewareCollectionAwareIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * class that can maintain before and after middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareCollectionAware = class(TInjectableObject, IMiddlewareCollectionAware)
    private
        beforeMiddlewareList : IMiddlewareCollection;
        afterMiddlewareList : IMiddlewareCollection;
    public
        constructor create(
            const beforeMiddlewares : IMiddlewareCollection;
            const afterMiddlewares : IMiddlewareCollection
        );
        destructor destroy(); override;
        function addBefore(middleware : IMiddleware) : IMiddlewareCollectionAware;
        function addAfter(middleware : IMiddleware) : IMiddlewareCollectionAware;
        function getBefore() : IMiddlewareCollection;
        function getAfter() : IMiddlewareCollection;
    end;

implementation

    constructor TMiddlewareCollectionAware.create(
        const beforeMiddlewares : IMiddlewareCollection;
        const afterMiddlewares : IMiddlewareCollection
    );
    begin
        inherited create();
        beforeMiddlewareList := beforeMiddlewares;
        afterMiddlewareList := afterMiddlewares;
    end;

    destructor TMiddlewareCollectionAware.destroy();
    begin
        beforeMiddlewareList := nil;
        afterMiddlewareList := nil;
        inherited destroy();
    end;

    function TMiddlewareCollectionAware.addBefore(middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        beforeMiddlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollectionAware.addAfter(middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        afterMiddlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollectionAware.getBefore() : IMiddlewareCollection;
    begin
        result := beforeMiddlewareList;
    end;

    function TMiddlewareCollectionAware.getAfter() : IMiddlewareCollection;
    begin
        result := afterMiddlewareList;
    end;

end.
