{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HttpClientImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HttpClientIntf,
    ResponseIntf,
    SerializeableIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * class that send HTTP GET to server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpClient = class(TInjectableObject, IHttpClient)
    private
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
        ) : IResponse; override;

    end;

implementation

uses

    libcurl;

    (*!------------------------------------------------
     * build URL with query string appended
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return url with query string appended
     *-----------------------------------------------*)
    function THttpClient.buildUrlWithQueryParams(
        const url : string;
        const data : ISerializeable = nil
    ) : string;
    var params : string;
    begin
        result := url;
        if (data <> nil) then
        begin
            params := data.serialize();
            if (pos('?', result) > 0) then
            begin
                //if we get here URL already contains query parameters
                result := result + params;
            end else
            begin
                //if we get here, URL has no query parameters
                result := result + '?' + params;
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
    function THttpClient.get(
        const url : string;
        const data : ISerializeable = nil
    ) : IResponse;
    var fullUrl : string;
    begin
        raiseExceptionIfCurlNotInitialized();
        fullUrl := buildUrlWithQueryParams(url, data);
        curl_easy_setopt(hCurl, CURLOPT_URL, [ fullUrl ]);
        executeCurl(hCurl);
        result := self;
    end;

    (*!------------------------------------------------
     * send HTTP request
     *-----------------------------------------------
     * @param url url to send request
     * @param data data related to this request
     * @return current instance
     *-----------------------------------------------*)
    function THttp.post(
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
