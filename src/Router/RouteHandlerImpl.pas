{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareIntf,
    RequestHandlerIntf,
    RouteHandlerIntf,
    RouteIntf,
    RouteArgsReaderIntf,
    RouteArgsWriterIntf,
    PlaceholderTypes,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic abstract class that can act as route handler
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouteHandler = class(TInjectableObject, IRouteHandler, IRequestHandler, IRouteArgsReader, IRouteArgsWriter, IRoute)
    private
        fMiddlewares : IMiddlewareCollectionAware;
        varPlaceholders : TArrayOfPlaceholders;
        fActualHandler : IRequestHandler;
        fRouteName : shortstring;
    public

        (*!-------------------------------------------
         * constructor
         *--------------------------------------------
         * @param amiddlewares object represent middlewares
         *--------------------------------------------*)
        constructor create(
            const amiddlewares : IMiddlewareCollectionAware;
            const actualHandler : IRequestHandler
        );

        (*!-------------------------------------------
         * destructor
         *--------------------------------------------*)
        destructor destroy(); override;

        (*!-------------------------------------------
         * method that handle request
         *--------------------------------------------
         * @param request object represent current request
         * @param response object represent current response
         * @return new response
         *--------------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse;

        (*!-------------------------------------------
         * Set route argument data
         *--------------------------------------------
         * @param placeHolders array of placeholders
         * @return current instance
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteArgsWriter;

        (*!-------------------------------------------
         * get route argument data
         *--------------------------------------------
         * @return current array of placeholders
         *--------------------------------------------*)
        function getArgs() : TArrayOfPlaceholders;

        (*!-------------------------------------------
         * get single route argument data
         *--------------------------------------------
         * @param key name of argument
         * @return placeholder
         *--------------------------------------------*)
        function getArg(const key : shortstring) : TPlaceholder;

        (*!-------------------------------------------
         * Set route name
         *--------------------------------------------
         * @param routeName name of route
         * @return current instance
         *--------------------------------------------*)
        function setName(const routeName : shortstring) : IRoute;

        (*!-------------------------------------------
         * get route name
         *--------------------------------------------
         * @return current route name
         *--------------------------------------------*)
        function getName() : shortstring;

        (*!-------------------------------------------
         * attach middleware before route
         *--------------------------------------------
         * @return current route instance
         *--------------------------------------------*)
        function before(const amiddleware : IMiddleware) : IRoute;

        (*!-------------------------------------------
         * attach middleware after route
         *--------------------------------------------
         * @return current route instance
         *--------------------------------------------*)
        function after(const amiddleware : IMiddleware) : IRoute;

        (*!-------------------------------------------
         * get route instance
         *--------------------------------------------
         * @return route instance
         *--------------------------------------------*)
        function route() : IRoute;

        (*!-------------------------------------------
         * get request handler
         *--------------------------------------------
         * @return request handler
         *--------------------------------------------*)
        function handler() : IRequestHandler;

        (*!-------------------------------------------
         * get router arguments writer
         *--------------------------------------------
         * @return route arguments writer instance
         *--------------------------------------------*)
        function argsWriter() : IRouteArgsWriter;

        (*!-------------------------------------------
         * get middlewares collection
         *--------------------------------------------
         * @return middleware collections
         *--------------------------------------------*)
        function middlewares() : IMiddlewareCollectionAware;
    end;

implementation

uses

    RouteConsts,
    ERouteArgNotFoundImpl;

    (*!-------------------------------------------
     * constructor
     *--------------------------------------------
     * @param amiddlewares object represent middlewares
     * @param viewInst view instance to use
     * @param viewParamsInt view parameters
     *--------------------------------------------*)
    constructor TRouteHandler.create(
        const amiddlewares : IMiddlewareCollectionAware;
        const actualHandler : IRequestHandler
    );
    begin
        inherited create();
        fMiddlewares := amiddlewares;
        fActualHandler := actualHandler;
        varPlaceholders := nil;
    end;

    destructor TRouteHandler.destroy();
    begin
        fMiddlewares := nil;
        fActualHandler := nil;
        varPlaceholders := nil;
        inherited destroy();
    end;

    (*!-------------------------------------------
     * Set route argument data
     *--------------------------------------------*)
    function TRouteHandler.setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;
    begin
        varPlaceholders := placeHolders;
        result := self;
    end;

    (*!-------------------------------------------
     * get route argument data
     *--------------------------------------------*)
    function TRouteHandler.getArgs() : TArrayOfPlaceholders;
    begin
        result := varPlaceholders;
    end;

    (*!-------------------------------------------
     * get single route argument data
     *--------------------------------------------*)
    function TRouteHandler.getArg(const key : shortstring) : TPlaceholder;
    var i, len:integer;
    begin
        len := length(varPlaceholders);
        for i:=0 to len-1 do
        begin
            if (key = varPlaceholders[i].name) then
            begin
                result := varPlaceholders[i];
                exit;
            end;
        end;
        raise ERouteArgNotFound.createFmt(sRouteArgNotFound, [key]);
    end;

    (*!-------------------------------------------
     * method that handle request
     *--------------------------------------------
     * @param request object represent current request
     * @param response object represent current response
     * @return new response
     *--------------------------------------------*)
    function TRouteHandler.handleRequest(
        const request : IRequest;
        const response : IResponse
    ) : IResponse;
    begin
        result := fActualHandler.handleRequest(request, response);
    end;

    (*!-------------------------------------------
     * Set route name
     *--------------------------------------------
     * @param routeName name of route
     * @return current instance
     *--------------------------------------------*)
    function TRouteHandler.setName(const routeName : shortstring) : IRoute;
    begin
        fRouteName := routeName;
        result := self;
    end;

    (*!-------------------------------------------
     * get route name
     *--------------------------------------------
     * @return current route name
     *--------------------------------------------*)
    function TRouteHandler.getName() : shortstring;
    begin
        result := fRouteName;
    end;

    (*!-------------------------------------------
     * attach middleware before route
     *--------------------------------------------
     * @return current route instance
     *--------------------------------------------*)
    function TRouteHandler.before(const amiddleware : IMiddleware) : IRoute;
    begin
        fMiddlewares.addBefore(amiddleware);
        result := self;
    end;

    (*!-------------------------------------------
     * attach middleware after route
     *--------------------------------------------
     * @return current route instance
     *--------------------------------------------*)
    function TRouteHandler.after(const amiddleware : IMiddleware) : IRoute;
    begin
        fMiddlewares.addAfter(amiddleware);
        result := self;
    end;

    (*!-------------------------------------------
     * get route instance
     *--------------------------------------------
     * @return route instance
     *--------------------------------------------*)
    function TRouteHandler.route() : IRoute;
    begin
        result := self;
    end;

    (*!-------------------------------------------
     * get request handler
     *--------------------------------------------
     * @return request handler
     *--------------------------------------------*)
    function TRouteHandler.handler() : IRequestHandler;
    begin
        result := self;
    end;

    (*!-------------------------------------------
     * get router arguments writer
     *--------------------------------------------
     * @return route arguments writer instance
     *--------------------------------------------*)
    function TRouteHandler.argsWriter() : IRouteArgsWriter;
    begin
        result := self;
    end;

    (*!-------------------------------------------
     * get middlewares collection
     *--------------------------------------------
     * @return middleware collections
     *--------------------------------------------*)
    function TRouteHandler.middlewares() : IMiddlewareCollectionAware;
    begin
        result := fMiddlewares;
    end;
end.
