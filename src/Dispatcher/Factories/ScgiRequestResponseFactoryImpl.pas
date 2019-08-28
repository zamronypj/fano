{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ScgiRequestResponseFactoryImpl;

interface

{$MODE OBJFPC}

uses

    RequestFactoryIntf,
    ResponseFactoryIntf,
    InjectableObjectImpl;

type

    (*!---------------------------------------------------
     * interface for any class having capability return
     * request and response factory
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TScgiRequestResponseFactory = class(TInjectableObject, IRequestResponseFactory)
    public
        function getRequestFactory() : IRequestFactory;
        function getResponseFactory() : IResponseFactory;
    end;

implementation

uses

    ScgiRequestFactoryImpl,
    ResponseFactoryImpl;

    function TScgiRequestResponseFactory.getRequestFactory() : IRequestFactory;
    begin
        result := TScgiRequestFactory.create();
    end;

    function TScgiRequestResponseFactory.getResponseFactory() : IResponseFactory;
    begin
        result := TResponseFactory.create();
    end;
end.
