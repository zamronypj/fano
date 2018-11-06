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
        jsonStr : string;
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

    sysutils;

    constructor TJsonResponse.create(const hdrs : IHeaders; const json : string);
    begin
        httpHeaders := hdrs;
        jsonStr := json;
    end;

    destructor TJsonResponse.destroy();
    begin
        inherited destroy();
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
        httpHeaders.setHeader('Content-Length', intToStr(length(jsonStr)));
        httpHeaders.writeHeaders();
        writeln(jsonStr);
        result := self;
    end;

    function TJsonResponse.clone() : ICloneable;
    var clonedObj : IResponse;
    begin
        clonedObj := TJsonResponse.create(
            httpHeaders.clone() as IHeaders,
            jsonStr
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
        //TODO: implement view response body
        result := nil;
    end;
end.
