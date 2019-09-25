{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareStackImpl;

interface

{$MODE OBJFPC}

uses

    Classes,
    RequestHandlerIntf,
    MiddlewareLinkListIntf,
    MiddlewareStackIntf;

type

    (*!------------------------------------------------
     * Basic class having capability to combine two middleware
     * link list as one
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareStack = class(TInterfacedObject, IMiddlewareStack)
    private
        fAppMiddlewares : IMiddlewareLinkList;
        fRouteMiddlewares : IMiddlewareLinkList;
        fHandler : IRequestHandler;
    public
        constructor create(
            const appMiddlewares : IMiddlewareLinkList;
            const routeMiddlewares : IMiddlewareLinkList;
            const handler : IRequestHandler
        );
        destructor destroy(); override;
        function getFirst() : IRequestHandler;
    end;

implementation

uses

    MiddlewareLinkIntf;

    constructor TMiddlewareStack.create(
        const appMiddlewares : IMiddlewareLinkList;
        const routeMiddlewares : IMiddlewareLinkList;
        const handler : IRequestHandler
    );
    var appLastLink, routeFirstLink{, routeLastLink} : IMiddlewareLink;
    begin
        fAppMiddlewares := appMiddlewares;
        fRouteMiddlewares := routeMiddlewares;
        fHandler := handler;
        if (fAppMiddlewares.count() > 0) then
        begin
            appLastLink := fAppMiddlewares.get(fAppMiddlewares.count() - 1);
            if (fRouteMiddlewares.count() > 0) then
            begin
                routeFirstLink := fRouteMiddlewares.get(0);
                appLastLink.next := routeFirstLink;
                // routeLastLink := fRouteMiddlewares.get(fRouteMiddlewares.count() - 1);
                // routeLastLink.next := fHandler;
            end else
            begin
                appLastLink.next := fHandler;
            end;
        end else
        begin
            if (fRouteMiddlewares.count() > 0) then
            begin
                //routeLastLink := fRouteMiddlewares.get(fRouteMiddlewares.count() - 1);
                //routeLastLink.next := fHandler;
            end;
        end;
    end;

    destructor TMiddlewareStack.destroy();
    var appLastLink{, routeFirstLink, routeLastLink} : IMiddlewareLink;
    begin
        if (fAppMiddlewares.count() > 0) then
        begin
            appLastLink := fAppMiddlewares.get(fAppMiddlewares.count() - 1);
            if (fRouteMiddlewares.count() > 0) then
            begin
                //routeFirstLink := fRouteMiddlewares.get(0);
                appLastLink.next := nil;
                // routeLastLink := fRouteMiddlewares.get(fRouteMiddlewares.count() - 1);
                // routeLastLink.next := fHandler;
            end else
            begin
                appLastLink.next := nil;
            end;
        end else

        fAppMiddlewares := nil;
        fRouteMiddlewares := nil;
        fHandler := nil;
        inherited destroy();
    end;

    function TMiddlewareStack.getFirst() : IRequestHandler;
    var totAppMiddleware, totRouteMiddleware : integer;
    begin
        totAppMiddleware := fAppMiddlewares.count();
        totRouteMiddleware := fRouteMiddlewares.count();
        if (totAppMiddleware > 0) or (totRouteMiddleware > 0) then
        begin
            if (totAppMiddleware > 0) then
            begin
                result := fAppMiddlewares.get(0);
            end else
            if (totRouteMiddleware > 0) then
            begin
                result := fRouteMiddlewares.get(0);
            end else
            begin
                //this should not happened
                result := fHandler;
            end;
        end else
        begin
            result := fHandler;
        end;
    end;

end.
