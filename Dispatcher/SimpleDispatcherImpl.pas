{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}
unit SimpleDispatcherImpl;

interface

{$MODE OBJFPC}

uses

    DispatcherIntf,
    DependencyIntf,
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf,
    RequestIntf,
    RequestFactoryIntf,
    RequestHandlerIntf,
    RouteHandlerIntf,
    RouteMatcherIntf;

type
    (*!------------------------------------------------
     * simple dispatcher implementation without
     * middleware support. It is faster than
     * TDispatcher because it does not process middlewares
     * stack during dispatching request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleDispatcher = class(TInterfacedObject, IDispatcher, IDependency)
    private
        routeCollection : IRouteMatcher;
        responseFactory : IResponseFactory;
        requestFactory : IRequestFactory;
    public
        constructor create(
            const routes : IRouteMatcher;
            const respFactory : IResponseFactory;
            const reqFactory : IRequestFactory
        );
        destructor destroy(); override;
        function dispatchRequest(const env: ICGIEnvironment) : IResponse;
    end;

implementation

uses
    sysutils;

    constructor TSimpleDispatcher.create(
        const routes : IRouteMatcher;
        const respFactory : IResponseFactory;
        const reqFactory : IRequestFactory
    );
    begin
        routeCollection := routes;
        responseFactory := respFactory;
        requestFactory := reqFactory;
    end;

    destructor TSimpleDispatcher.destroy();
    begin
        inherited destroy();
        routeCollection := nil;
        responseFactory := nil;
        requestFactory := nil;
    end;

    function TSimpleDispatcher.dispatchRequest(const env: ICGIEnvironment) : IResponse;
    var routeHandler : IRouteHandler;
        method : string;
        uriParts : TStringArray;
    begin
        try
            method := env.requestMethod();
            //remove any query string parts
            uriParts := env.requestUri().split('?');
            routeHandler := routeCollection.match(method, uriParts[0]);
            result := routeHandler.handleRequest(
                requestFactory.build(env),
                responseFactory.build(env)
            );
        finally
            routeHandler := nil;
            uriParts := nil;
        end;
    end;
end.
