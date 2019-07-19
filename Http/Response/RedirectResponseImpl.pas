{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RedirectResponseImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    ResponseIntf,
    ResponseStreamIntf,
    HeadersIntf;

type
    (*!------------------------------------------------
     * base JSON response class
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRedirectResponse = class(TInterfacedObject, IResponse)
    private
        httpHeaders : IHeaders;
        fStatus : word;
        fUrl : string;
        fStream : IResponseStream;

        function redirectCodeMessage(const code : word) : string;
    public
        constructor create(const hdrs : IHeaders; const status : word; const url : string);
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
    end;

implementation

uses

    sysutils,
    ResponseStreamImpl;

    constructor TRedirectResponse.create(const hdrs : IHeaders; const json : string);
    begin
        httpHeaders := hdrs;
        fStream := TNullResponseStream.create();
    end;

    destructor TRedirectResponse.destroy();
    begin
        inherited destroy();
        fStream := nil;
        httpHeaders := nil;
    end;

    function TRedirectResponse.redirectCodeMessage(const code : word) : string;
    begin
        case code of
            300 : result := 'Multiple Choice';
            301 : result := 'Moved Permanently';
            302 : result := 'Found';
            303 : result := 'See Other';
            304 : result := 'Not Modified';
            305 : result := 'Use Proxy';
            306 : result := 'Switch Proxy';
            307 : result := 'Temporary Redirect';
            308 : result := 'Permanent Redirect';
        end;
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TRedirectResponse.headers() : IHeaders;
    begin
        result := httpHeaders;
    end;

    function TRedirectResponse.write() : IResponse;
    begin
        httpHeaders.setHeader('Status: ', intToStr(fStatus) + ' ' + redirectCodeMessage(fStatus));
        httpHeaders.setHeader('Location', fUrl);
        httpHeaders.writeHeaders();
        result := self;
    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TRedirectResponse.body() : IResponseStream;
    begin
        result := fStream;
    end;
end.
