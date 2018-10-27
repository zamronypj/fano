{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit CombineRouteCollectionFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TCombineRegexRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCombineRouteCollectionFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    RouteCollectionImpl,
    CombineRegexRouteListImpl,
    RegexImpl,
    HashListImpl;

    function TCombineRouteCollectionFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouteCollection.create(
            TCombineRegexRouteList.create(
                TRegex.create(),
                THashList.create()
            )
        );
    end;

end.
