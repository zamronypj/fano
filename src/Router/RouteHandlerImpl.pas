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

        function getActualMiddlewares() : IMiddlewareCollectionAware;
        function IMiddlewareCollectionAware.getMiddlewares = getActualMiddlewares;
    public
        constructor create(const aMiddlewares : IMiddlewareCollectionAware);
        destructor destroy(); override;

        function getMiddlewares() : IMiddlewareCollectionAware;

        function handleRequest(
            const request : IRequest;
            const response : IResponse
        ) : IResponse; virtual; abstract;

        (*!-------------------------------------------
         * Set route argument data
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;

        (*!-------------------------------------------
         * get route argument data
         *--------------------------------------------*)
        function getArgs() : TArrayOfPlaceholders;

        (*!-------------------------------------------
         * get single route argument data
         *--------------------------------------------*)
        function getArg(const key : string) : TPlaceholder;
    end;

implementation

uses

    ERouteArgNotFoundImpl;

resourcestring

    sRouteArgNotFound = 'Route argument %s not found';

    constructor TRouteHandler.create(const aMiddlewares : IMiddlewareCollectionAware);
    begin
        inherited create();
        fMiddlewares := aMiddlewares;
        varPlaceholders := nil;
    end;

    destructor TRouteHandler.destroy();
    begin
        fMiddlewares := nil;
        varPlaceholders := nil;
        inherited destroy();
    end;

    function TRouteHandler.getActualMiddlewares() : IMiddlewareCollectionAware;
    begin
        result := fMiddlewares;
    end;

    function TRouteHandler.getMiddlewares() : IMiddlewareCollectionAware;
    begin
        result := self;
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
