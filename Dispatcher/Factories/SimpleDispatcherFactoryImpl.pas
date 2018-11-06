{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit SimpleDispatcherFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RouteMatcherIntf;

type

    (*!--------------------------------------------------
     * factory class for TSimpleDispatcher,
     * route dispatcher implementation which does not support
     * middleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TSimpleDispatcherFactory = class(TFactory, IDependencyFactory)
    private
        routeMatcher : IRouteMatcher;
    public
        constructor create (const routeMatcherInst : IRouteMatcher);
        destructor destroy(); override;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    SimpleDispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl;

    constructor TSimpleDispatcherFactory.create(
        const routeMatcherInst : IRouteMatcher
    );
    begin
        routeMatcher := routeMatcherInst;
    end;

    destructor TSimpleDispatcherFactory.destroy();
    begin
        inherited destroy();
        routeMatcher := nil;
    end;

    function TSimpleDispatcherFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TSimpleDispatcher.create(
            routeMatcher,
            TResponseFactory.create(),
            TRequestFactory.create()
        );
    end;

end.
