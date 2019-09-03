{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BaseCorsMiddlewareFactoryImpl;

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
     * basic abstract class having capability to create
     * middleware chain instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TBaseCorsMiddlewareFactory = class(TFactory)
    protected
        fAllowedOrigins : TStringArray;
        fAllowedOriginsPatterns : TStringArray;
        fAllowedMethods : TStringArray;
        fAllowedHeaders : TStringArray;
        fExposedHeaders : TStringArray;
        fSupportsCredentials : boolean;
        fMaxAge : integer;
    public
        function allowedOrigins(const allowedOriginArr : array of string) : IDependencyFactory;
        function allowedOriginsPatterns(const patternArr : array of string) : IDependencyFactory;
        function allowedMethods(const methods : array of string) : IDependencyFactory;
        function allowedHeaders(const hdrs : array of string) : IDependencyFactory;
        function exposedHeaders(const hdrs : array of string) : IDependencyFactory;
        function maxAge(const age : integer) : IDependencyFactory;
        function supportsCredentials(const supportCred : boolean) : IDependencyFactory;
    end;

implementation

uses

    CorsMiddlewareImpl,
    CorsImpl,
    CorsConfigImpl,
    NullCorsImpl,
    RegexImpl;

    (*!------------------------------------------------
     * make TStringArray from open array
     *
     * @author Fungus
     * @credit https://forum.lazarus.freepascal.org/index.php/topic,34601.msg227098.html#msg227098
     *-------------------------------------------------*)
    function makeStringArray(const arr : array of string) : TStringArray;
    var i, len: Integer;
    begin
        len := high(arr) - low(arr) + 1;
        setLength(result, len);
        for i:= 0 to len - 1 do
        begin
            result[i] := arr[i];
        end;
    end;

    function TBaseCorsMiddlewareFactory.allowedOrigins(const allowedOriginArr : array of string) : IDependencyFactory;
    begin
        fAllowedOrigins := makeStringArray(allowedOriginArr);
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.allowedOriginsPatterns(const patternArr : array of string) : IDependencyFactory;
    begin
        fAllowedOriginsPatterns := makeStringArray(patternArr);
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.allowedMethods(const methods : array of string) : IDependencyFactory;
    begin
        fAllowedMethods := makeStringArray(methods);
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.allowedHeaders(const hdrs : array of string) : IDependencyFactory;
    begin
        fAllowedHeaders := makeStringArray(hdrs);
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.exposedHeaders(const hdrs : array of string) : IDependencyFactory;
    begin
        fExposedHeaders := makeStringArray(hdrs);
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.maxAge(const age : integer) : IDependencyFactory;
    begin
        fMaxAge := age;
        result := self;
    end;

    function TBaseCorsMiddlewareFactory.supportsCredentials(const supportCred : boolean) : IDependencyFactory;
    begin
        fSupportsCredentials := supportCred;
        result := self;
    end;

end.
