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
        fNextLink : IMiddlewareLink;
    public
        constructor create(const middlewareInst : IMiddleware);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            const routeArgs : IRouteArgsReader
        ) : IResponse;

        procedure setNext(const next : IMiddlewareLink);
        function getNext() : IMiddlewareLink;

    end;

implementation

    constructor TMiddlewareLink.create(
        const middlewareInst : IMiddleware
    );
    begin
        fMiddleware := middlewareInst;
        fNextLink := nil;
    end;

    destructor TMiddlewareLink.destroy();
    begin
        fMiddleware := nil;
        fNextLink := nil;
        inherited destroy();
    end;

    function TMiddlewareLink.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const routeArgs : IRouteArgsReader
    ) : IResponse;
    begin
        result := fMiddleware.handleRequest(request, response, routeArgs, fNextLink);
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
