{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteCollectionFactoryImpl;

interface

{$MODE OBJFPC}

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRouteCollectionFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    RouteCollectionImpl,
    RouteListImpl;

    function TRouteCollectionFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouteCollection.create(TRouteList.create());
    end;

end.
