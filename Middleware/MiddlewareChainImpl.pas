{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareChainImpl;

interface

{$MODE OBJFPC}

uses

    MiddlewareIntf,
    MiddlewareChainIntf,
    RequestHandlerIntf,
    RequestIntf,
    ResponseIntf,
    MiddlewareCollectionIntf;

type

    (*!------------------------------------------------
     * class that chain one or more middlewares and have
     * capability to execute middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareChain = class(TInterfacedObject, IMiddlewareChain)
    private
        ///application global middleware list executed before route handler
        appBeforeMiddlewareList : IMiddlewareCollection;

        ///application global middleware list executed after route handler
        appAfterMiddlewareList : IMiddlewareCollection;

        ///route middleware list executed before route handler
        routeBeforeMiddlewareList : IMiddlewareCollection;

        ///route middleware list executed after route handler
        routeAfterMiddlewareList : IMiddlewareCollection;

        function executeMiddlewares(
            const middlewares : IMiddlewareCollection;
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;

        function executeBeforeMiddlewares(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;

        function executeAfterMiddlewares(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    public
        constructor create(
            const appBeforeMiddlewares : IMiddlewareCollection;
            const appAfterMiddlewares : IMiddlewareCollection;
            const routeBeforeMiddlewares : IMiddlewareCollection;
            const routeAfterMiddlewares : IMiddlewareCollection
        );

        destructor destroy(); override;

        function execute(
            const request : IRequest;
            const response : IResponse;
            const requestHandler : IRequestHandler
        ) : IResponse;
    end;

implementation

    constructor TMiddlewareChain.create(
        const appBeforeMiddlewares : IMiddlewareCollection;
        const appAfterMiddlewares : IMiddlewareCollection;
        const routeBeforeMiddlewares : IMiddlewareCollection;
        const routeAfterMiddlewares : IMiddlewareCollection
    );
    begin
        appBeforeMiddlewareList := appBeforeMiddlewares;
        appAfterMiddlewareList := appAfterMiddlewares;
        routeBeforeMiddlewareList := routeBeforeMiddlewares;
        routeAfterMiddlewareList := routeAfterMiddlewares;
    end;

    destructor TMiddlewareChain.destroy();
    begin
        inherited destroy();
        appBeforeMiddlewareList := nil;
        appAfterMiddlewareList := nil;
        routeBeforeMiddlewareList := nil;
        routeAfterMiddlewareList := nil;
    end;

    function TMiddlewareChain.executeMiddlewares(
        const middlewares : IMiddlewareCollection;
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    var i, len : integer;
        newResponse : IResponse;
        middleware : IMiddleware;
    begin
        newResponse := response;
        len := middlewares.count();
        for i := 0 to len-1 do
        begin
            middleware := middlewares.get(i);
            newResponse := middleware.handleRequest(request, newResponse, canContinue);
            if (not canContinue) then
            begin
                result := newResponse;
                exit();
            end;
        end;
        result := newResponse;
    end;

    function TMiddlewareChain.executeBeforeMiddlewares(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    var beforeMiddlewares : IMiddlewareCollection;
    begin
        beforeMiddlewares := appBeforeMiddlewareList.merge(routeBeforeMiddlewareList);
        result := executeMiddlewares(beforeMiddlewares, request, response, canContinue);
    end;

    function TMiddlewareChain.executeAfterMiddlewares(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    var afterMiddlewares : IMiddlewareCollection;
    begin
        afterMiddlewares := appAfterMiddlewareList.merge(routeAfterMiddlewareList);
        result := executeMiddlewares(afterMiddlewares, request, response, canContinue);
    end;

    function TMiddlewareChain.execute(
        const request : IRequest;
        const response : IResponse;
        const requestHandler : IRequestHandler
    ) : IResponse;
    var canContinue : boolean;
        newResponse : IResponse;
    begin
        canContinue := true;
        newResponse := executeBeforeMiddlewares(request, response, canContinue);
        if (canContinue) then
        begin
            newResponse := requestHandler.handleRequest(request, newResponse);
            newResponse := executeAfterMiddlewares(request, newResponse, canContinue);
        end;
        result := newResponse;
    end;
end.
