{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouterHandlerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    MiddlewareCollectionFactory,
    RequestHandlerIntf,
    RouteHandlerFactoryIntf;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TSimpleRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRouterHandlerFactory = class(TInterfacedObject, IRouteHandlerFactory)
    private
        fMiddlewareCollectionFactory : IMiddlewareCollectionFactory;
    public
        constructor create(const middlewareCollectionFactory : IMiddlewareCollectionFactory);
        destructor destroy(); override;
        function build(const handler : IRequestHandler) : IRequestHandler;
    end;

implementation

uses

    RouterHandlerImpl;

    constructor TRouterHandlerFactory.create(const middlewareCollectionFactory : IMiddlewareCollectionFactory);
    begin
        fMiddlewareCollectionFactory := middlewareCollectionFactory;
    end;

    destructor TRouterHandlerFactory.destroy();
    begin
        fMiddlewareCollectionFactory := nil;
        inherited destroy();
    end

    function TRouterHandlerFactory.build(const handler : IRequestHandler) : IRequestHandler;
    begin
        result := TRouteHandler.create(fMiddlewareCollectionFactory.build(), handler);
    end;

end.
