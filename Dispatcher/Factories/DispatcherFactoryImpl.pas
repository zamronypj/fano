{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit DispatcherFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RouteMatcherIntf,
    MiddlewareCollectionAwareIntf;

type

    (*!--------------------------------------------------
     * factory class for TDispatcher,
     * route dispatcher implementation which support middleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TDispatcherFactory = class(TFactory, IDependencyFactory)
    private
        appMiddlewares : IMiddlewareCollectionAware;
        routeMatcher : IRouteMatcher;
    public
        constructor create (
            const appMiddlewaresInst : IMiddlewareCollectionAware;
            const routeMatcherInst : IRouteMatcher
        );
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    DispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl,
    MiddlewareChainFactoryImpl;

    constructor TDispatcherFactory.create(
        const appMiddlewaresInst : IMiddlewareCollectionAware;
        const routeMatcherInst : IRouteMatcher
    );
    begin
        appMiddlewares := appMiddlewaresInst;
        routeMatcher := routeMatcherInst;
    end;

    destructor TDispatcherFactory.destroy();
    begin
        inherited destroy();
        appMiddlewares := nil;
        routeMatcher := nil;
    end;

    function TDispatcherFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TDispatcher.create(
            appMiddlewares.getBefore(),
            appMiddlewares.getAfter(),
            TMiddlewareChainFactory.create(),
            routeMatcher,
            TResponseFactory.create(),
            TRequestFactory.create()
        );
    end;

end.
