{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DefaultMiddlewareLinkImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    RouteArgsReaderIntf,
    RequestHandlerIntf,
    MiddlewareIntf,
    MiddlewareLinkIntf;

type

    (*!------------------------------------------------
     * internal class which wrap a request handler
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TDefaultMiddlewareLink = class(TInterfacedObject, IMiddlewareLink, IRequestHandler)
    private
        fDefaultHandler : IRequestHandler;
    public
        constructor create(const handler : IRequestHandler);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const routeArgs : IRouteArgsReader
        ) : IResponse;

        procedure setNext(const next : IRequestHandler);
        function getNext() : IRequestHandler;

    end;

implementation

    constructor TDefaultMiddlewareLink.create(const handler : IRequestHandler);
    begin
        fDefaultHandler := handler;
    end;

    destructor TDefaultMiddlewareLink.destroy();
    begin
        fDefaultHandler := nil;
        inherited destroy();
    end;

    function TDefaultMiddlewareLink.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const routeArgs : IRouteArgsReader
    ) : IResponse;
    begin
        result := fDefaultHandler.handleRequest(request, response, routeArgs);
    end;

    procedure TDefaultMiddlewareLink.setNext(const next : IRequestHandler);
    begin
    end;

    function TDefaultMiddlewareLink.getNext() : IRequestHandler;
    begin
        result := nil;
    end;
end.
