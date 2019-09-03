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
    private
        fAllowedOrigins : TStringArray;
    public
        function allowedOrigins(const allowedOriginArr : TStringArray) : IDependencyFactory;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    CorsMiddlewareImpl,
    CorsImpl,
    CorsConfigImpl,
    NullCorsImpl,
    RegexImpl;

    function TCorsMiddlewareFactory.allowedOrigins(const allowedOriginArr : TStringArray) : IDependencyFactory;
    begin
        fAllowedOrigins := allowedOriginArr;
        result := self;
    end;

    function TCorsMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCorsMiddleware.create(
            TCors.create(
                TCorsConfig.create(
                    fAllowedOrigins
                ),
                TRegex.create()
            )
        );
    end;
end.
