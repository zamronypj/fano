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
    MiddlewareCollectionIntf,
    MiddlewareChainFactoryIntf,
    RouteHandlerIntf,
    MiddlewareCollectionAwareIntf,
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
        applicationMiddlewares : IMiddlewareCollectionAware;
        middlewareChainFactory : IMiddlewareChainFactory;

        function executeMiddlewareChain(
            const env: ICGIEnvironment;
            const stdIn : IStdIn;
            const routeHandler : IRouteHandler;
            const routeMiddlewares : IMiddlewareCollectionAware
        ) : IResponse;

        function executeMiddlewares(
            const env: ICGIEnvironment;
            const stdIn : IStdIn;
            const routeHandler : IRouteHandler
        ) : IResponse;
    public
        constructor create(
            const appMiddlewares : IMiddlewareCollectionAware;
            const chainFactory : IMiddlewareChainFactory;
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

uses

    MiddlewareChainIntf;

    constructor TDispatcher.create(
        const appMiddlewares : IMiddlewareCollectionAware;
        const chainFactory : IMiddlewareChainFactory;
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        inherited create(routes, respFactory, reqFactory);
        applicationMiddlewares := appMiddlewares;
        middlewareChainFactory := chainFactory;
    end;

    destructor TDispatcher.destroy();
    begin
        applicationMiddlewares := nil;
        middlewareChainFactory := nil;
        inherited destroy();
    end;

    function TDispatcher.executeMiddlewareChain(
        const env: ICGIEnvironment;
        const stdIn : IStdIn;
        const routeHandler : IRouteHandler;
        const routeMiddlewares : IMiddlewareCollectionAware;
    ) : IResponse;
    var middlewareChain : IMiddlewareChain;
    begin
        middlewareChain := middlewareChainFactory.build(
            applicationMiddlewares,
            routeMiddlewares
        );
        try
            result := middlewareChain.execute(
                requestFactory.build(env, stdIn),
                responseFactory.build(env),
                routeHandler
            );
        finally
            middlewareChain := nil;
        end;
    end;

    function TDispatcher.executeMiddlewares(
        const env: ICGIEnvironment;
        const stdIn : IStdIn;
        const routeHandler : IRouteHandler
    ) : IResponse;
    var routeMiddlewares : IMiddlewareCollectionAware;
    begin
        routeMiddlewares := routeHandler as IMiddlewareCollectionAware;
        try
            result := executeMiddlewareChain(env, stdIn, routeHandler, routeMiddlewares);
        finally
            routeMiddlewares := nil;
        end;
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
