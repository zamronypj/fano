{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RouteHandlerImpl;

interface

uses
    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    MiddlewareCollectionIntf,
    MiddlewareCollectionAwareIntf,
    RouteHandlerIntf;

type
    {------------------------------------------------
     base class for route handler
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRouteHandler = class(TInterfacedObject, IRouteHandler, IMiddlewareCollectionAware)
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
        function getMiddlewares() : IMiddlewareCollectionAware;
        function getBefore() : IMiddlewareCollection;
        function getAfter() : IMiddlewareCollection;
        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse; virtual; abstract;
    end;

implementation

    constructor TRouteHandler.create(
        const beforeMiddlewares : IMiddlewareCollection;
        const afterMiddlewares : IMiddlewareCollection
    );
    begin
        beforeMiddlewareList := beforeMiddlewares;
        afterMiddlewareList := afterMiddlewares;
    end;

    destructor TRouteHandler.destroy();
    begin
        inherited destroy();
        beforeMiddlewareList := nil;
        afterMiddlewareList := nil;
    end;

    function TRouteHandler.addBefore(const middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        beforeMiddlewareList.add(middleware);
        result := self;
    end;

    function TRouteHandler.addAfter(const middleware : IMiddleware) : IMiddlewareCollectionAware;
    begin
        afterMiddlewareList.add(middleware);
        result := self;
    end;

    function TRouteHandler.getBefore() : IMiddlewareCollection;
    begin
        result := beforeMiddlewareList;
    end;

    function TRouteHandler.getAfter() : IMiddlewareCollection;
    begin
        result := afterMiddlewareList;
    end;

    function TRouteHandler.getMiddlewares() : IMiddlewareCollectionAware;
    begin
        result := self;
    end;

end.
