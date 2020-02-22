{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MhdResponseImpl;

interface

{$MODE OBJFPC}

uses

    HeadersIntf,
    ResponseStreamIntf,
    CloneableIntf,
    libmicrohttpd;

type

    (*!----------------------------------------------
     * class having capability as HTTP response for libmocrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdResponse = class (TInterfacedObject, IHeaders, IResponse)
    private
        fConnection : PMHD_Connection;
    public
        (*!------------------------------------
         * set http header
         *-------------------------------------
         * @param key name  of http header to set
         * @param value value of header
         * @return header instance
         *-------------------------------------*)
        function setHeader(const key : shortstring; const value : string) : IHeaders;

        (*!------------------------------------
         * add http header
         *-------------------------------------
         * @param key name  of http header to set
         * @param value value of header
         * @return header instance
         *-------------------------------------*)
        function addHeader(const key : shortstring; const value : string) : IHeaders;

        (*!------------------------------------
         * output http headers to STDOUT
         *-------------------------------------
         * Implementor must end with empty blank line
         * after write all headers
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function writeHeaders() : IHeaders;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IHeaders;

        (*!------------------------------------
         * output http response to STDOUT
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

    (*!------------------------------------
     * set http header
     *-------------------------------------
     * @param key name  of http header to set
     * @param value value of header
     * @return header instance
     *-------------------------------------*)
    function setHeader(const key : shortstring; const value : string) : IHeaders;

    (*!------------------------------------
     * add http header
     *-------------------------------------
     * @param key name  of http header to set
     * @param value value of header
     * @return header instance
     *-------------------------------------*)
    function addHeader(const key : shortstring; const value : string) : IHeaders;
    begin


    (*!------------------------------------
        * output http headers to STDOUT
        *-------------------------------------
        * Implementor must end with empty blank line
        * after write all headers
        *-------------------------------------
        * @return header instance
        *-------------------------------------*)
    function writeHeaders() : IHeaders;
    begin
        MHD_add_response_header (response, "Content-Type", MIMETYPE);
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TMhdResponse.headers() : IHeaders;
    begin
        result := self;
    end;

    (*!------------------------------------
     * output http response to STDOUT
     *-------------------------------------
     * @return current instance
     *-------------------------------------*)
    function TMhdResponse.write() : IResponse;
    begin

    end;

    (*!------------------------------------
     * get response body
     *-------------------------------------
     * @return response body
     *-------------------------------------*)
    function TMhdResponse.body() : IResponseStream;
    begin
    end;

    function TMhdResponse.clone() : ICloneable;
    begin
    end;
end.
