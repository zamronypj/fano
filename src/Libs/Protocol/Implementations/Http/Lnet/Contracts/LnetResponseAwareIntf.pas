{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetResponseAwareIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    lhttp;

type

    (*!------------------------------------------------
     * interface for any class having maintain TLHTTPServer
     * output instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ILnetResponseAware = interface
        ['{D0C8A4F9-DB61-423F-A5FB-7F65EF8F7E28}']

        (*!------------------------------------------------
         * get TLHTTPServer output object
         *-----------------------------------------------
         * @return connection
         *-----------------------------------------------*)
        function getResponse() : TOutputItem;

        (*!------------------------------------------------
         * set TLHTTPServer output
         *-----------------------------------------------*)
        procedure setResponse(aoutput : TOutputItem);

        property response : TOutputItem read getResponse write setResponse;
    end;

implementation

end.
