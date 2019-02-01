{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit GetImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    HttpClientIntf;

type

    (*!------------------------------------------------
     * class that send HTTP GET to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpGet = class(TInjectableObject, IHttpClient)
    public

        (*!------------------------------------------------
         * send HTTP request
         *-----------------------------------------------
         * @param url url to send request
         * @param context object instance related to this message
         * @return current logger instance
         *-----------------------------------------------*)
        function send(
            const url : string;
            const context : ISerializeable = nil
        ) : IResponse;

    end;

implementation

end.
