{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpPostImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    InjectableObjectImpl,
    HttpClientIntf;

type

    (*!------------------------------------------------
     * class that send HTTP POST to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpPost = class(TInjectableObject, IHttpClient)
    public

        (*!------------------------------------------------
         * send HTTP request
         *-----------------------------------------------
         * @param url url to send request
         * @param context object instance related to this message
         * @return current instance
         *-----------------------------------------------*)
        function send(
            const url : string;
            const context : ISerializeable = nil
        ) : IResponse;

    end;

implementation

    (*!------------------------------------------------
     * send HTTP request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------*)
    function THttpPost.send(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponse;
    var hCurl : pCurl;
        params : string;
    begin
        hCurl:= curl_easy_init();
        if assigned(hCurl) then
        begin
            curl_easy_setopt(hCurl,CURLOPT_URL, [url]);
            if (data <> nil) then
            begin
                params := data.serialize();
                curl_easy_setopt(hCurl,CURLOPT_POSTFIELDS, [ params ]);
            end;
            curl_easy_perform(hCurl);
            curl_easy_cleanup(hCurl);
        end;
        result := self;
    end;

end.
