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
    MiddlewareCollectionAwareIntf;

type

    (*!------------------------------------------------
     * class that can maintain before and after middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
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
        function addBefore(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function addAfter(const middleware : IMiddleware) : IMiddlewareCollectionAware;
        function getBefore() : IMiddlewareCollection;
        function getAfter() : IMiddlewareCollection;
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

    function TMiddlewareCollectionAware.addBefore(const middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        beforeMiddlewareList.add(middleware);
        result := self;
    end;

    function TMiddlewareCollectionAware.addAfter(const middleware : IMiddleware) : IMiddlewareCollectionAware;
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
