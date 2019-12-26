{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ResponseIntf;

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
    TMhdResponse = class (TInterfacedObject, IResponse)
    public
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
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TMhdResponse.headers() : IHeaders;
    begin
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
