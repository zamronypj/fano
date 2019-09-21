{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteHandlerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    MiddlewareCollectionAwareFactoryIntf,
    RequestHandlerIntf,
    RouteHandlerIntf,
    RouteHandlerFactoryIntf;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TSimpleRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRouteHandlerFactory = class(TInterfacedObject, IRouteHandlerFactory)
    private
        fMiddlewareCollectionFactory : IMiddlewareCollectionAwareFactory;
    public
        constructor create(const middlewareCollectionFactory : IMiddlewareCollectionAwareFactory);
        destructor destroy(); override;
        function build(const handler : IRequestHandler) : IRouteHandler;
    end;

implementation

uses

    RouterHandlerImpl;

    constructor TRouteHandlerFactory.create(const middlewareCollectionFactory : IMiddlewareCollectionFactory);
    begin
        fMiddlewareCollectionFactory := middlewareCollectionFactory;
    end;

    destructor TRouteHandlerFactory.destroy();
    begin
        fMiddlewareCollectionFactory := nil;
        inherited destroy();
    end

    function TRouteHandlerFactory.build(const handler : IRequestHandler) : IRouteHandler;
    begin
        result := TRouteHandler.create(fMiddlewareCollectionFactory.build(), handler);
    end;

end.
