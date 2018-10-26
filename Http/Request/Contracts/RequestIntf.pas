{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RequestIntf;

interface

{$H+}

uses

    KeyValueTypes;

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
         * @return array of TQueryParam
         *------------------------------------------------*)
        function getQueryParams() : TArrayOfKeyValue;

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
         * @return array of TQueryParam
         *------------------------------------------------*)
        function getCookieParams() : TArrayOfKeyValue;
    end;

implementation
end.
