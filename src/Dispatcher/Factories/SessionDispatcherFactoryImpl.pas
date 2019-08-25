{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SessionDispatcherFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RouteMatcherIntf,
    MiddlewareCollectionAwareIntf,
    MiddlewareChainFactoryIntf,
    DispatcherFactoryImpl;

type

    (*!--------------------------------------------------
     * factory class for TDispatcher,
     * route dispatcher implementation which support middleware
     * and session
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TSessionDispatcherFactory = class(TDispatcherFactory)
    protected
        function createMiddlewareChainFactory() : IMiddlewareChainFactory; override;
    end;

implementation

uses

    SessionMiddlewareChainFactoryImpl;

    function TSessionDispatcherFactory.createMiddlewareChainFactory() : IMiddlewareChainFactory;
    begin
        result := TSessionMiddlewareChainFactory.create();
    end;

end.
