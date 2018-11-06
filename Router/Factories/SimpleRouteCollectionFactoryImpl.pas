{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit SimpleRouteCollectionFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TSimpleRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TSimpleRouteCollectionFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    RouteCollectionImpl,
    SimpleRegexRouteListImpl,
    RegexImpl,
    HashListImpl;

    function TSimpleRouteCollectionFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouteCollection.create(
            TSimpleRegexRouteList.create(
                TRegex.create(),
                THashList.create()
            )
        );
    end;

end.
