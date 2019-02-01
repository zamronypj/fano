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

    libcurl,
    InjectableObjectImpl,
    HttpClientIntf,
    ResponseIntf,
    SerializeableIntf;

type

    (*!------------------------------------------------
     * base class for HTTP operation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    THttpMethod = class(TInjectableObject, IHttpClient)
    private
        (*!------------------------------------------------
        * raise exception if curl operation fail
        *-----------------------------------------------
        * @param errCode curl error code
        *-----------------------------------------------*)
        procedure raiseExceptionIfError(const errCode : CurlCode);
    protected
        (*!------------------------------------------------
        * execute curl operation and raise exception if fail
        *-----------------------------------------------
        * @param hCurl curl handle
        * @return errCode curl error code
        *-----------------------------------------------*)
        function executeCurl(const hCurl : pCurl) : CurlCode;
    public

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
        ) : IResponse; virtual; abstract;

    end;

implementation

uses

    EHttpClientErrorImpl;


    (*!------------------------------------------------
     * raise exception if curl operation fail
     *-----------------------------------------------
     * @param errCode curl error code
     *-----------------------------------------------*)
    procedure THttpMethod.raiseExceptionIfError(const errCode : CurlCode);
    var errMsg : string;
    begin
        if (errCode <> CURLE_OK) then
        begin
            //operation fail, raise exception
            errMsg := curl_easy_strerror(errCode);
            raise EHttpClientErrorImpl.create(errMsg);
        end;
    end;

    (*!------------------------------------------------
    * execute curl operation and raise exception if fail
    *-----------------------------------------------
    * @param hCurl curl handle
    * @return errCode curl error code
    *-----------------------------------------------*)
    function THttpMethod.executeCurl(const hCurl : pCurl) : CurlCode;
    begin
        result := curl_easy_perform(hCurl);
        raiseExceptionIfError(result);
    end;

end.
