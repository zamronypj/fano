{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    classes,
    ResponseIntf,
    ResponseStreamIntf,
    HeadersIntf,
    CloneableIntf,
    fpjson;

type
    (*!------------------------------------------------
     * base JSON response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonResponse = class(TInterfacedObject, IResponse, ICloneable)
    private
        httpHeaders : IHeaders;
        responseStream : IResponseStream;
        jsonStream : TStringStream;
    public
        constructor create(const hdrs : IHeaders; const json : string);
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        function write() : IResponse;
        function clone() : ICloneable;

        (*!------------------------------------
         * get response body
         *-------------------------------------
         * @return response body
         *-------------------------------------*)
        function body() : IResponseStream;
    end;

implementation

uses

    sysutils,
    ResponseStreamImpl;

    constructor TJsonResponse.create(const hdrs : IHeaders; const json : string);
    begin
        httpHeaders := hdrs;
        jsonStream := TStringStream.create(json);
        responseStream := TResponseStream.create(jsonStream, false);
    end;

    destructor TJsonResponse.destroy();
    begin
        inherited destroy();
        jsonStream.free();
        responseStream := nil;
        httpHeaders := nil;
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TJsonResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    function TJsonResponse.write() : IResponse;
    begin
        httpHeaders.setHeader('Content-Type', 'application/json');
        httpHeaders.setHeader('Content-Length', intToStr(jsonStream.size));
        httpHeaders.writeHeaders();
        writeln(jsonStream.dataString);
        result := self;
    end;

    function TJsonResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TJsonResponse.create(
            httpHeaders.clone() as IHeaders,
            jsonStream.dataString
        );
        result := clonedObj;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TJsonResponse.body() : IResponseStream;
    begin
        result := responseStream;
    end;
end.
