{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit HeadersIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    CloneableIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * set and write HTTP headers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IHeaders = interface(ICloneable)
        ['{8CFE49E5-F77A-4949-B748-C2C63A6735C3}']

        (*!------------------------------------
         * set http header
         *-------------------------------------
         * @param key name  of http header to set
         * @param value value of header
         * @return header instance
         *-------------------------------------*)
        function setHeader(const key : shortstring; const value : string) : IHeaders;

        (*!------------------------------------
         * get http header
         *-------------------------------------
         * @param key name  of http header to get
         * @return header value
         * @throws EHeaderNotSet
         *-------------------------------------*)
        function getHeader(const key : shortstring) : string;

        (*!------------------------------------
         * test if http header already been set
         *-------------------------------------
         * @param key name  of http header to test
         * @return boolean true if header is set
         *-------------------------------------*)
        function has(const key : shortstring) : boolean;

        (*!------------------------------------
         * output http headers to STDIN
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function writeHeaders() : IHeaders;
    end;

implementation
end.
