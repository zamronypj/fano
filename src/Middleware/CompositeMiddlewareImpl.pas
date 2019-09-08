{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeMiddlewareImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    MiddlewareIntf,
    InjectableObjectImpl;

type

    TMiddlewareArray = array of IMiddleware;

    (*!------------------------------------------------
     * midlleware class that is composed from several
     * external middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCompositeMiddleware = class(TInjectableObject, IMiddleware)
    private
        fMiddlewares : TMiddlewareArray;
        procedure freeMiddlewares(var middlewares : TMiddlewareArray);
        function initMiddlewares(const middlewares : array of IMiddleware) : TMiddlewareArray;
    public
        constructor create(const middlewares : array of IMiddleware);
        destructor destroy(); override;

        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;
    end;

implementation

    constructor TCompositeMiddleware.create(const middlewares : array of IMiddleware);
    begin
        fMiddlewares := initMiddlewares(middlewares);
    end;

    destructor TCompositeMiddleware.destroy();
    begin
        freeMiddlewares(fMiddlewares);
        inherited destroy();
    end;

    function TCompositeMiddleware.initMiddlewares(const middlewares : array of IMiddleware) : TMiddlewareArray;
    var i, totMiddlewares : integer;
    begin
        totMiddlewares := high(middlewares) - low(middlewares) + 1;
        setLength(result, totMiddlewares);
        for i := 0 to totMiddlewares - 1 do
        begin
            result[i] := middlewares[i];
        end;
    end;

    procedure TCompositeMiddleware.freeMiddlewares(var middlewares : TMiddlewareArray);
    var i, totMiddlewares : integer;
    begin
        totMiddlewares := length(middlewares);
        for i := 0 to totMiddlewares - 1 do
        begin
            middlewares[i] := nil;
        end;
        setLength(middlewares, 0);
        middlewares := nil;
    end;

    function TCompositeMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    var i, totMiddlewares : integer;
        newResponse : IResponse;
    begin
        totMiddlewares := length(fMiddlewares);
        newResponse := response;
        for i:= 0 to totMiddlewares - 1 do
        begin
            if not canContinue then
            begin
                break;
            end;
            newResponse := fMiddlewares[i].handleRequest(
                request,
                newResponse,
                canContinue
            );
        end;
        result := newResponse;
    end;
end.
