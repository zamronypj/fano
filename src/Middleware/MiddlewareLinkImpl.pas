{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareLinkImpl;

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
     * internal class which wrap a middleware to be able
     * be linked with others
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareLink = class(TInterfacedObject, IMiddlewareLink, IRequestHandler)
    private
        fMiddleware : IMiddleware;
        fNextLink : IRequestHandler;
        fDefaultHandler : IRequestHandler;
    public
        constructor create(const middlewareInst : IMiddleware);
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

uses

    NullRequestHandlerImpl;

    constructor TMiddlewareLink.create(
        const middlewareInst : IMiddleware
    );
    begin
        fMiddleware := middlewareInst;
        fNextLink := nil;
        fDefaultHandler := TNullRequestHandler.create();
    end;

    destructor TMiddlewareLink.destroy();
    begin
        fMiddleware := nil;
        fNextLink := nil;
        fDefaultHandler := nil;
        inherited destroy();
    end;

    function TMiddlewareLink.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const routeArgs : IRouteArgsReader
    ) : IResponse;
    var nextHandler : IRequestHandler;
    begin
        if (fNextLink = nil) then
        begin
            nextHandler := fDefaultHandler;
        end else
        begin
            nextHandler := fNextLink;
        end;
        result := fMiddleware.handleRequest(request, response, routeArgs, nextHandler);
    end;

    procedure TMiddlewareLink.setNext(const next : IMiddlewareLink);
    begin
        fNextLink := next;
    end;

    function TMiddlewareLink.getNext() : IMiddlewareLink;
    begin
        result := fNextLink;
    end;
end.
