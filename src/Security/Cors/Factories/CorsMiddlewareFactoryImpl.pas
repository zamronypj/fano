{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CorsMiddlewareFactoryImpl;

interface

{$MODE OBJFPC}

uses

    FactoryImpl,
    DependencyContainerIntf,
    DependencyIntf;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCorsMiddlewareFactory = class(TFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    CorsMiddlewareImpl,
    CorsImpl,
    CorsConfigImpl,
    RegexImpl;

    function TCorsMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    var cors : ICors;
    begin
        cors := TCors.create(
            nil,
            TRegex.create()
        );
        result := TCorsMiddleware.create(cors);
    end;
end.
