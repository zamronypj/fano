{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpClientIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to send
     * HTTP request to a server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IHttpClient = interface
        ['{944E1D4F-08BA-446C-A662-9C1EC27DEF74}']

        (*!------------------------------------------------
         * send HTTP request
         *-----------------------------------------------
         * @param url url to send request
         * @param data data related to this request
         * @return current instance
         *-----------------------------------------------*)
        function send(
            const url : string;
            const data : ISerializeable = nil
        ) : IResponse;

    end;

implementation

end.
