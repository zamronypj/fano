{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseFactoryImpl;

interface

{$MODE OBJFPC}

uses
    EnvironmentIntf,
    ResponseIntf,
    ResponseFactoryIntf;

type
    (*!------------------------------------------------
     * TResponse factory class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponseFactory = class(TInterfacedObject, IResponseFactory)
    public
        function build(const env : ICGIEnvironment) : IResponse;
    end;

implementation
uses
    ResponseImpl,
    HeadersImpl,
    HashListImpl;

    function TResponseFactory.build(const env : ICGIEnvironment) : IResponse;
    begin
        result := TResponse.create(env, THeaders.create(THashList.create()));
    end;
end.
