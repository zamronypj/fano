{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiRequestResponseFactoryImpl;

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
    TFcgiRequestResponseFactory = class(TInjectableObject, IRequestResponseFactory)
    public
        function getRequestFactory() : IRequestFactory;
        function getResponseFactory() : IResponseFactory;
    end;

implementation

uses

    FcgiRequestFactoryImpl,
    ResponseFactoryImpl;

    function TFcgiRequestResponseFactory.getRequestFactory() : IRequestFactory;
    begin
        result := TFcgiRequestFactory.create();
    end;

    function TFcgiRequestResponseFactory.getResponseFactory() : IResponseFactory;
    begin
        result := TResponseFactory.create();
    end;
end.
