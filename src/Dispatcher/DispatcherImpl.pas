{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DispatcherImpl;

interface

{$MODE OBJFPC}

uses

    DispatcherIntf,
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestFactoryIntf,
    RouteMatcherIntf,
    RouteHandlerIntf,
    MiddlewareExecutorIntf,
    StdInIntf,
    InjectableObjectImpl,
    BaseDispatcherImpl;

type

    (*!---------------------------------------------------
     * Request dispatcher class having capability dispatch
     * request and return response and with middleware support
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TDispatcher = class(TBaseDispatcher)
    private
        fMiddlewareExecutor : IMiddlewareExecutor;

        function executeMiddlewares(
            const env: ICGIEnvironment;
            const stdIn : IStdIn;
            const routeHandler : IRouteHandler
        ) : IResponse;
    public
        constructor create(
            const middlewareExecutor : IMiddlewareExecutor;
            const routes : IRouteMatcher;
            const respFactory : IResponseFactory;
            const reqFactory : IRequestFactory
        );
        destructor destroy(); override;

        (*!-------------------------------------------
         * dispatch request
         *--------------------------------------------
         * @param env CGI environment
         * @param stdIn STDIN reader
         * @return response
         *--------------------------------------------*)
        function dispatchRequest(
            const env: ICGIEnvironment;
            const stdIn : IStdIn
        ) : IResponse; override;
    end;

implementation

    constructor TDispatcher.create(
        const middlewareExecutor : IMiddlewareExecutor;
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        inherited create(routes, respFactory, reqFactory);
        fMiddlewareExecutor := middlewareExecutor;
    end;

    destructor TDispatcher.destroy();
    begin
        fMiddlewareExecutor := nil;
        inherited destroy();
    end;

    function TDispatcher.executeMiddlewares(
        const env: ICGIEnvironment;
        const stdIn : IStdIn;
        const routeHandler : IRouteHandler
    ) : IResponse;
    begin
        result := middlewareExecutor.execute(
            requestFactory.build(env, stdIn),
            responseFactory.build(env),
            routeHandler
        );
    end;

    function TDispatcher.dispatchRequest(
        const env: ICGIEnvironment;
        const stdIn : IStdIn
    ) : IResponse;
    var routeHandler : IRouteHandler;
    begin
        routeHandler := getRouteHandler(env);
        try
            result := executeMiddlewares(env, stdIn, routeHandler);
        finally
            routeHandler := nil;
        end;
    end;
end.
