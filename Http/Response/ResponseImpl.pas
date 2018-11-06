{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseImpl;

interface

{$MODE OBJFPC}

uses
    EnvironmentIntf,
    ResponseIntf,
    HeadersIntf,
    ResponseStreamIntf,
    CloneableIntf;

type
    (*!------------------------------------------------
     * base Http response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TResponse = class(TInterfacedObject, IResponse, ICloneable)
    private
        webEnvironment : ICGIEnvironment;
        httpHeaders : IHeaders;
        bodyStream : IResponseStream;
    public
        constructor create(const env : ICGIEnvironment; const hdrs : IHeaders);
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        (*!------------------------------------
         * output http response to STDIN
         *-------------------------------------
         * @return current instance
         *-------------------------------------*)
        function write() : IResponse;

        (*!------------------------------------
         * get response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function body() : IResponseStream;

        function clone() : ICloneable;
    end;

implementation

    constructor TResponse.create(const env : ICGIEnvironment; const hdrs : IHeaders);
    begin
        webEnvironment := env;
        httpHeaders := hdrs;
        //TODO: implement response body stream
        bodyStream := nil;
    end;

    destructor TResponse.destroy();
    begin
        inherited destroy();
        webEnvironment := nil;
        httpHeaders := nil;
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    function TResponse.write() : IResponse;
    begin
        httpHeaders.writeHeaders();
        result := self;
    end;

    function TResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TResponse.create(webEnvironment, httpHeaders.clone() as IHeaders);
        //TODO : copy any property
        result := clonedObj;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TResponse.body() : IResponseStream;
    begin
        result := bodyStream;
    end;
end.
