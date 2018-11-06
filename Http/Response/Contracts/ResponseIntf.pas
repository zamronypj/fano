{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ResponseIntf;

interface

{$MODE OBJFPC}

uses

    HeadersIntf,
    ResponseStreamIntf,
    CloneableIntf;

type

    (*!----------------------------------------------
     * interface for any class having capability as
     * HTTP response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IResponse = interface(ICloneable)
        ['{36D6274C-3EE1-4262-BACB-2A313C673206}']

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
    end;

implementation
end.
