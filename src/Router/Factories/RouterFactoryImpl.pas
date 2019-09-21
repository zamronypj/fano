{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouterFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    AbstractRouterFactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRouterFactory = class(TAbstractRouterFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    RouterImpl,
    RouteListImpl,
    RouteHandlerFactoryImpl;

    function TRouterFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouter.create(
            TRouteList.create(),
            TRouteHandlerFactory.create(getMiddlewareFactory())
        );
    end;

end.
