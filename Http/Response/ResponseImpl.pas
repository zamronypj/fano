{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit ResponseImpl;

interface

uses
    EnvironmentIntf,
    ResponseIntf,
    HeadersIntf,
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
    public
        constructor create(const env : ICGIEnvironment; const hdrs : IHeaders);
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        function write() : IResponse;
        function clone() : ICloneable;
    end;

implementation

    constructor TResponse.create(const env : ICGIEnvironment; const hdrs : IHeaders);
    begin
        webEnvironment := env;
        httpHeaders := hdrs;
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
        clonedObj := TResponse.create(webEnvironment, httpHeaders.clone());
        //TODO : copy any property
        result := clonedObj;
    end;
end.
