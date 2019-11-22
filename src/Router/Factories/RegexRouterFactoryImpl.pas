{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RegexRouterFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    AbstractRouterFactoryImpl;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TRegexRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRegexRouterFactory = class(TAbstractRouterFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    RouterImpl,
    RegexRouteListImpl,
    RegexImpl,
    HashListImpl,
    RouteHandlerFactoryImpl;

    function TRegexRouterFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TRouter.create(
            TRegexRouteList.create(
                TRegex.create(),
                THashList.create()
            ),
            TRouteHandlerFactory.create(getMiddlewareFactory())
        );
    end;

end.
