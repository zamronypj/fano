{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareExecutorImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareListIntf,
    MiddlewareExecutorIntf,
    RouteArgsReaderIntf,
    RouteHandlerIntf;

type

    (*!------------------------------------------------
     * class having capability to execute middlewares stack
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareExecutor = class(TInterfacedObject, IMiddlewareExecutor)
    private
        fAppMiddlewares : IMiddlewareList;
    public
        constructor create(const appMiddlewares : IMiddlewareList);
        destructor destroy(); override;
        function execute(
            const request : IRequest;
            const response : IResponse;
            const routeHandler : IRouteHandler
        ) : IResponse;
    end;

implementation

uses

    MiddlewareStackIntf,
    MiddlewareStackImpl;

    constructor TMiddlewareExecutor.create(const appMiddlewares : IMiddlewareList);
    begin
        fAppMiddlewares := appMiddlewares;
    end;

    destructor TMiddlewareExecutor.destroy();
    begin
        fAppMiddlewares := nil;
        inherited destroy();
    end;

    function TMiddlewareExecutor.execute(
        const request : IRequest;
        const response : IResponse;
        const routeHandler : IRouteHandler
    ) : IResponse;
    var mdlwr : IMiddlewareStack;
    begin
        mdlwr := TMiddlewareStack.create(
            fAppMiddlewares,
            routeHandler.middlewares(),
            routeHandler.handler()
        );

        result := mddlwr.first.handleRequest(
            request,
            response,
            routeHandler.argsReader()
        );
    end;
end.
