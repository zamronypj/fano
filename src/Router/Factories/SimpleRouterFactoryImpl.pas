{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SimpleRouterFactoryImpl;

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
    TSimpleRouterFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    RouterImpl,
    SimpleRegexRouteListImpl,
    RegexImpl,
    HashListImpl,
    RouteHandlerFactoryImpl;

    function TSimpleRouterFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouter.create(
            TSimpleRegexRouteList.create(
                TRegex.create(),
                THashList.create()
            ),
            TRouteHandlerFactory.create()
        );
    end;

end.
