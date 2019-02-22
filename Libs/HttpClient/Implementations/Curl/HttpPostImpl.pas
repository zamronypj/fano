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
    HttpPostClientIntf,
    ResponseStreamIntf,
    SerializeableIntf;

type

    (*!------------------------------------------------
     * class that send HTTP POST to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpPost = class(THttpMethod, IHttpPostClient)
    public

        (*!------------------------------------------------
         * send HTTP request
         *-----------------------------------------------
         * @param url url to send request
         * @param context object instance related to this message
         * @return response from server
         *-----------------------------------------------*)
        function post(
            const url : string;
            const context : ISerializeable = nil
        ) : IResponse;

    end;

implementation

uses

    libcurl;

    (*!------------------------------------------------
     * send HTTP POST request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------*)
    function THttpPost.post(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponse;
    var params : string;
    begin
        raiseExceptionIfCurlNotInitialized();
        streamInst.reset();
        curl_easy_setopt(hCurl, CURLOPT_URL, [ PChar(url) ]);
        if (data <> nil) then
        begin
            params := data.serialize();
            curl_easy_setopt(hCurl, CURLOPT_POSTFIELDS, [ PChar(params) ]);
        end;
        executeCurl(hCurl);
        result := streamInst;
    end;

end.
