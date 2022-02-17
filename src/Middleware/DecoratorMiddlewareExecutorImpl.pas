{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DecoratorMiddlewareExecutorImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    RouteHandlerIntf,
    MiddlewareExecutorIntf;

type

    (*!------------------------------------------------
     * decorator class having capability to
     * execute middlewares stack
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDecoratorMiddlewareExecutor = class (TInterfacedObject, IMiddlewareExecutor)
    protected
        fExecutor : IMiddlewareExecutor;
    public
        constructor create(const aExecutor : IMiddlewareExecutor);

        function execute(
            const request : IRequest;
            const response : IResponse;
            const routeHandler : IRouteHandler
        ) : IResponse; virtual;
    end;

implementation

    constructor TDecoratorMiddlewareExecutor.create(const aExecutor : IMiddlewareExecutor);
    begin
        fExecutor := aExecutor;
    end;

    function TDecoratorMiddlewareExecutor.execute(
        const request : IRequest;
        const response : IResponse;
        const routeHandler : IRouteHandler
    ) : IResponse;
    begin
        result := fExecutor.execute(request, response, routeHandler);
    end;

end.
