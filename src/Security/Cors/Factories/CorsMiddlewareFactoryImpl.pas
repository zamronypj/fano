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
{$H+}

uses

    FactoryImpl,
    DependencyContainerIntf,
    DependencyIntf,
    SysUtils;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCorsMiddlewareFactory = class(TFactory)
    private
        fAllowedOrigins : array of string;
        function makeStringArray(const arr : array of string) : TStringArray;
    public
        function allowedOrigins(const allowedOriginArr : array of string) : IDependencyFactory;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    CorsMiddlewareImpl,
    CorsImpl,
    CorsConfigImpl,
    NullCorsImpl,
    RegexImpl;

    function TCorsMiddlewareFactory.makeStringArray(const arr : array of string) : TStringArray;
    var i, len: Integer;
    begin
        len := high(arr) - low(arr) + 1;
        setLength(result, len);
        for i:= 0 to len - 1 do
        begin
            result[i] := arr[i];
        end;
    end;

    function TCorsMiddlewareFactory.allowedOrigins(const allowedOriginArr : array of string) : IDependencyFactory;
    begin
        fAllowedOrigins := allowedOriginArr;
        result := self;
    end;

    function TCorsMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TCorsMiddleware.create(
            TCors.create(
                TCorsConfig.create(
                    makeStringArray(fAllowedOrigins)
                ),
                TRegex.create()
            )
        );
    end;
end.
