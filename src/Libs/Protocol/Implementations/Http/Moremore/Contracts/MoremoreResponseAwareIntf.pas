{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MoremoreResponseAwareIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    mormot.net.http;

type

    (*!------------------------------------------------
     * interface for any class having maintain Moremore HTTP server
     * response instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMoremoreResponseAware = interface
        ['{798D0CC6-CD3E-4C7B-BE6E-943D502D3B55}']

        (*!------------------------------------------------
         * get THTTPAsyncServer response connection
         *-----------------------------------------------
         * @return connection
         *-----------------------------------------------*)
        function getResponse() : THttpServerRequestAbstract;

        (*!------------------------------------------------
         * set THttpServerRequestAbstract response object
         *-----------------------------------------------*)
        procedure setResponse(ctxt: THttpServerRequestAbstract);

        property response: THttpServerRequestAbstract read getResponse write setResponse;
    end;

implementation

end.
