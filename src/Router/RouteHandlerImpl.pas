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

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareCollectionAwareIntf,
    RouteHandlerIntf,
    PlaceholderTypes,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic abstract class that can act as route handler
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouteHandler = class(TInjectableObject, IRouteHandler, IMiddlewareCollectionAware)
    private
        fMiddlewares : IMiddlewareCollectionAware;
        varPlaceholders : TArrayOfPlaceholders;
    public

        (*!-------------------------------------------
         * constructor
         *--------------------------------------------
         * @param middlewares object represent middlewares
         *--------------------------------------------*)
        constructor create(const middlewares : IMiddlewareCollectionAware);

        (*!-------------------------------------------
         * destructor
         *--------------------------------------------*)
        destructor destroy(); override;

        (*!-------------------------------------------
         * abstract method that handle request
         *--------------------------------------------
         * @param request object represent current request
         * @param response object represent current response
         * @return new response
         *--------------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse; virtual; abstract;

        (*!-------------------------------------------
         * Set route argument data
         *--------------------------------------------
         * @param placeHolders array of placeholders
         * @return current instance
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;

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

        property middlewares : IMiddlewareCollectionAware read fMiddlewares implements IMiddlewareCollectionAware;
    end;

implementation

uses

    RouteConsts,
    ERouteArgNotFoundImpl;

    (*!-------------------------------------------
     * constructor
     *--------------------------------------------
     * @param middlewares object represent middlewares
     * @param viewInst view instance to use
     * @param viewParamsInt view parameters
     *--------------------------------------------*)
    constructor TRouteHandler.create(const middlewares : IMiddlewareCollectionAware);
    begin
        inherited create();
        fMiddlewares := middlewares;
        varPlaceholders := nil;
    end;

    destructor TRouteHandler.destroy();
    begin
        fMiddlewares := nil;
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
    function TRouteHandler.getArg(const key : string) : TPlaceholder;
    var i, len:integer;
    begin
        len := length(varPlaceholders);
        for i:=0 to len-1 do
        begin
            if (key = varPlaceholders[i].phName) then
            begin
                result := varPlaceholders[i];
                exit;
            end;
        end;
        raise ERouteArgNotFound.createFmt(sRouteArgNotFound, [key]);
    end;

end.
