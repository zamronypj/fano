{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NotModifiedResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    CloneableIntf,
    ResponseIntf,
    ResponseStreamIntf,
    HeadersIntf;

type
    (*!------------------------------------------------
     * not modified response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TNotModifiedResponse = class(TInterfacedObject, IResponse)
    private
        httpHeaders : IHeaders;
        fStream : IResponseStream;
    public
        (*!------------------------------------
         * constructor
         *-------------------------------------
         * @param hdrs header conllection instance
         *-------------------------------------*)
        constructor create(const hdrs : IHeaders);
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        function write() : IResponse;

        (*!------------------------------------
         * get response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function body() : IResponseStream;

        (*!------------------------------------
         * set new response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function setBody(const newBody : IResponseStream) : IResponse;

        function clone() : ICloneable;
    end;

implementation

uses

    sysutils,
    NullResponseStreamImpl;

    (*!------------------------------------
     * constructor
     *-------------------------------------
     * @param hdrs header conllection instance
     * @param url target url to redirect
     * @param status, optional HTTP redirection status, default is 302
     *-------------------------------------*)
    constructor TNotModifiedResponse.create(
        const hdrs : IHeaders
    );
    begin
        inherited create();
        //304 response does not need body, so we just use null stream
        fStream := TNullResponseStream.create();
        httpHeaders := hdrs;
    end;

    destructor TNotModifiedResponse.destroy();
    begin
        fStream := nil;
        httpHeaders := nil;
        inherited destroy();
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TNotModifiedResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    function TNotModifiedResponse.write() : IResponse;
    begin
        httpHeaders.setHeader('Status', intToStr(fStatus) + ' ' + redirectCodeMessage(fStatus));
        httpHeaders.writeHeaders();
        result := self;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TNotModifiedResponse.body() : IResponseStream;
    begin
        result := fStream;
    end;

    (*!------------------------------------
     * set new response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TNotModifiedResponse.setBody(const newBody : IResponseStream) : IResponse;
    begin
        //intentionally does nothing as redirect response do not need body
        result := self;
    end;

    function TNotModifiedResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TNotModifiedResponse.create(
            httpHeaders.clone() as IHeaders
        );
        result := clonedObj;
    end;

end.
