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

    HttpMethodImpl,
    ResponseStreamIntf,
    SerializeableIntf;

type

    (*!------------------------------------------------
     * class that send HTTP POST to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpPost = class(THttpMethod)
    public

        (*!------------------------------------------------
         * send HTTP request
         *-----------------------------------------------
         * @param url url to send request
         * @param context object instance related to this message
         * @return response from server
         *-----------------------------------------------*)
        function send(
            const url : string;
            const context : ISerializeable = nil
        ) : IResponse; override;

    end;

implementation

uses

    libcurl;

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
    var params : string;
    begin
        raiseExceptionIfCurlNotInitialized();
        curl_easy_setopt(hCurl, CURLOPT_URL, [url]);
        if (data <> nil) then
        begin
            params := data.serialize();
            curl_easy_setopt(hCurl, CURLOPT_POSTFIELDS, [ params ]);
        end;
        executeCurl(hCurl);
        result := self;
    end;

end.
