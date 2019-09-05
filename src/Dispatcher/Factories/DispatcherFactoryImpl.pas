{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DispatcherFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    RouteMatcherIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareChainFactoryIntf,
    RequestResponseFactoryIntf,
    SimpleDispatcherFactoryImpl;

type

    (*!--------------------------------------------------
     * factory class for TDispatcher,
     * route dispatcher implementation which support middleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TDispatcherFactory = class(TSimpleDispatcherFactory)
    private
        appMiddlewares : IMiddlewareCollectionAware;
    protected
        function createMiddlewareChainFactory() : IMiddlewareChainFactory; virtual;
    public
        constructor create (
            const appMiddlewaresInst : IMiddlewareCollectionAware;
            const routeMatcher : IRouteMatcher;
            const requestResponseFactory : IRequestResponseFactory
        );
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    DispatcherImpl,
    RequestResponseFactoryImpl,
    MiddlewareChainFactoryImpl;

    constructor TDispatcherFactory.create(
        const appMiddlewaresInst : IMiddlewareCollectionAware;
        const routeMatcher : IRouteMatcher;
        const requestResponseFactory : IRequestResponseFactory
    );
    begin
        inherited create(routeMatcher, requestResponseFactory);
        appMiddlewares := appMiddlewaresInst;
    end;

    destructor TDispatcherFactory.destroy();
    begin
        appMiddlewares := nil;
        inherited destroy();
    end;

    function TDispatcherFactory.createMiddlewareChainFactory() : IMiddlewareChainFactory;
    begin
        result := TMiddlewareChainFactory.create();
    end;

    function TDispatcherFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TDispatcher.create(
            appMiddlewares,
            createMiddlewareChainFactory(),
            fRouteMatcher,
            fRequestResponseFactory.responseFactory,
            fRequestResponseFactory.requestFactory
        );
    end;

end.
