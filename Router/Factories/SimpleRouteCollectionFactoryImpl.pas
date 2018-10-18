{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit SimpleRouteCollectionFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

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
