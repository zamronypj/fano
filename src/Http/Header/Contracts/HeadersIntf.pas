{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HeadersIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    ReadOnlyHeadersIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * set and write HTTP headers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IHeaders = interface(IReadOnlyHeaders)
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
         * output http headers to STDOUT
         *-------------------------------------
         * Implementor must end with empty blank line
         * after write all headers
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function writeHeaders() : IHeaders;
    end;

implementation
end.
