{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RequestHandlerAsMiddlewareImpl;

interface

{$MODE OBJFPC}

uses
    RequestIntf,
    ResponseIntf,
    RequestHandlerIntf,
    RouteArgsReaderIntf,
    MiddlewareIntf;

type

    (*!------------------------------------------------
     * adapter class that wrap request handler so it can
     * act as a middleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRequestHandlerAsMiddleware = class(TInterfacedObject, IMiddleware)
    private
        requestHandler : IRequestHandler;
    public
        constructor create(const requestHandlerInst : IRequestHandler);
        destructor destroy(); override;
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const routeArgs : IRouteArgsReader;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

    constructor TRequestHandlerAsMiddleware.create(
        const requestHandlerInst : IRequestHandler
    );
    begin
        requestHandler := requestHandlerInst;
    end;

    destructor TRequestHandlerAsMiddleware.destroy();
    begin
        requestHandler := nil;
        inherited destroy();
    end;

    function TRequestHandlerAsMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const routeArgs : IRouteArgsReader;
        var canContinue : boolean
    ) : IResponse;
    begin
        canContinue := true;
        result := requestHandler.handleRequest(request, response, routeArgs);
    end;
end.
