{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit VerbTunnellingRequestResponseFactoryImpl;

interface

{$MODE OBJFPC}

uses

    RequestFactoryIntf,
    ResponseFactoryIntf,
    RequestResponseFactoryIntf,
    InjectableObjectImpl;

type

    (*!---------------------------------------------------
     * class having capability return request and response
     * factory which support verb tunnelling
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TVerbTunnellingRequestResponseFactory = class(TInjectableObject, IRequestResponseFactory)
    public
        function getRequestFactory() : IRequestFactory;
        function getResponseFactory() : IResponseFactory;
    end;

implementation

uses

    RequestFactoryImpl,
    VerbTunnellingRequestFactoryImpl,
    ResponseFactoryImpl;

    function TVerbTunnellingRequestResponseFactory.getRequestFactory() : IRequestFactory;
    begin
        result := TVerbTunnellingRequestFactory.create(TRequestFactory.create());
    end;

    function TVerbTunnellingRequestResponseFactory.getResponseFactory() : IResponseFactory;
    begin
        result := TResponseFactory.create();
    end;
end.
