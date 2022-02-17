{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit WithExceptMiddlewareExecutorImpl;

interface

{$MODE OBJFPC}

uses

    RequestIntf,
    ResponseIntf,
    RouteHandlerIntf,
    MiddlewareExecutorIntf,
    DecoratorMiddlewareExecutorImpl;

type

    (*!------------------------------------------------
     * decorator class having capability to
     * execute middlewares stack and rethrow any exception
     * as EHttpException.
     * This class is implemented to fix issue response headers
     * set previously gone when exception is raised
     * https://github.com/fanoframework/fano/issues/17
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TWithExceptMiddlewareExecutor = class (TDecoratorMiddlewareExecutor)
    public
        function execute(
            const request : IRequest;
            const response : IResponse;
            const routeHandler : IRouteHandler
        ) : IResponse; override;
    end;

implementation

uses

    sysutils,
    EHttpExceptionImpl,
    EInternalServerErrorImpl;

    function TWithExceptMiddlewareExecutor.execute(
        const request : IRequest;
        const response : IResponse;
        const routeHandler : IRouteHandler
    ) : IResponse;
    begin
        try
            result := inherited execute(request, response, routeHandler);
        except
            on e: EHttpException do
            begin
                //re raise but make sure add response header so that
                //it is not gone (see Issue #17)
                e.headers := e.headers + response.headers.asString();
                raise e;
            end;

            on e: Exception do
            begin
                //re raise but add response header so that
                //it is not gone (see Issue #17)
                raise EInternalServerError.create(
                    //add original class name in exception message
                    //so that we know type of original exception is
                    '(' + e.ClassName . ') ' + e.Message,
                    response.headers.asString()
                );
            end;
        end;
    end;

end.
