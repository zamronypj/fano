{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RequestIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    HashListIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * HTTP request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IRequest = interface
        ['{32913245-599A-4BF4-B25D-7E2EF349F7BB}']

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getQueryParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all query params
         *-------------------------------------------------
         * @return list of query string params
         *------------------------------------------------*)
        function getQueryParams() : IHashList;

        (*!------------------------------------------------
         * get single cookie param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getCookieParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all cookies params
         *-------------------------------------------------
         * @return list of cookie params
         *------------------------------------------------*)
        function getCookieParams() : IHashList;

        (*!------------------------------------------------
         * get request body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParsedBodyParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all request body data
         *-------------------------------------------------
         * @return array of parsed body params
         *------------------------------------------------*)
        function getParsedBodyParams() : IHashList;

        (*!------------------------------------------------
         * test if current request is coming from AJAX request
         *-------------------------------------------------
         * @return true if ajax request false otherwise
         *------------------------------------------------*)
        function isXhr() : boolean;
    end;

implementation
end.
