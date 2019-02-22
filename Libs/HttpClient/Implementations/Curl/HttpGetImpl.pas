{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpGetImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HttpMethodImpl,
    HttpGetClientIntf,
    ResponseStreamIntf,
    SerializeableIntf;

type

    (*!------------------------------------------------
     * class that send HTTP GET to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpGet = class(THttpMethod, IHttpGetClient)
    private
        (*!------------------------------------------------
         * append query params
         *-----------------------------------------------
         * @param url url to send request
         * @param params query string
         * @return url with query string appended
         *-----------------------------------------------*)
        function appendQueryParams(
            const url : string;
            const params : string
        ) : string;

        (*!------------------------------------------------
         * build URL with query string appended
         *-----------------------------------------------
         * @param url url to send request
         * @param data data related to this request
         * @return url with query string appended
         *-----------------------------------------------*)
        function buildUrlWithQueryParams(
            const url : string;
            const data : ISerializeable = nil
        ) : string;
    public

        (*!------------------------------------------------
         * send HTTP GET request
         *-----------------------------------------------
         * @param url url to send request
         * @param data data related to this request
         * @return response from server
         *-----------------------------------------------*)
        function get(
            const url : string;
            const data : ISerializeable = nil
        ) : IResponseStream;

    end;

implementation

uses

    libcurl,
    ResponseImpl,
    HeadersImpl,
    HashListImpl,
    ResponseStreamImpl;

    (*!------------------------------------------------
     * append query params
     *-----------------------------------------------
     * @param url url to send request
     * @param params query string
     * @return url with query string appended
     *-----------------------------------------------*)
    function THttpGet.appendQueryParams(
        const url : string;
        const params : string
    ) : string;
    begin
        if (pos('?', url) > 0) then
        begin
            //if we get here URL already contains query parameters
            result := url + params;
        end else
        begin
            //if we get here, URL has no query parameters
            result := url + '?' + params;
        end;
    end;

    (*!------------------------------------------------
     * build URL with query string appended
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return url with query string appended
     *-----------------------------------------------*)
    function THttpGet.buildUrlWithQueryParams(
        const url : string;
        const data : ISerializeable = nil
    ) : string;
    var params : string;
    begin
        result := url;
        if (data <> nil) then
        begin
            params := data.serialize();
            if (length(params) > 0) then
            begin
                result := appendQueryParams(result, params);
            end;
        end;
    end;

    (*!------------------------------------------------
     * send HTTP GET request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------
     * @credit: https://github.com/graemeg/freepascal/blob/master/packages/libcurl/examples/testcurl.pp
     *-----------------------------------------------*)
    function THttpGet.get(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponseStream;
    var fullUrl : PChar;
    begin
        raiseExceptionIfCurlNotInitialized();
        fullUrl := PChar(buildUrlWithQueryParams(url, data));
        curl_easy_setopt(hCurl, CURLOPT_URL, [ fullUrl ]);
        executeCurl(hCurl);
        result := streamInst;
    end;

end.
