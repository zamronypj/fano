{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FpwebRequestImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf,
    AjaxAwareIntf,
    ReadOnlyListIntf,
    UploadedFileIntf,
    UploadedFileCollectionIntf,
    ReadonlyHeadersIntf,
    EnvironmentIntf,
    UriIntf,
    fphttpserver;

type

    (*!------------------------------------------------
     * fcl-web TRequest adapter class implement IRequest
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFpwebRequest = class(TInterfacedObject, IRequest)
    private
        fRequest : TFPHttpConnectionRequest;
    public
        constructor create(const request : TFPHttpConnectionRequest);
        destructor destroy(); override;

        (*!------------------------------------------------
         * test if current request is coming from AJAX request
         *-------------------------------------------------
         * @return true if ajax request false otherwise
         *------------------------------------------------*)
        function isXhr() : boolean;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IReadOnlyHeaders; virtual;

        (*!------------------------------------------------
         * get request URI
         *-------------------------------------------------
         * @return IUri of current request
         *------------------------------------------------*)
        function uri() : IUri; virtual;

        (*!------------------------------------------------
         * get request method GET, POST, HEAD, etc
         *-------------------------------------------------
         * @return string request method
         *------------------------------------------------*)
        function getMethod() : string; virtual;

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getQueryParam(
            const key: string;
            const defValue : string = ''
        ) : string; virtual;

        (*!------------------------------------------------
         * get all query params
         *-------------------------------------------------
         * @return list of query string params
         *------------------------------------------------*)
        function getQueryParams() : IReadOnlyList; virtual;

        (*!------------------------------------------------
         * get single cookie param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getCookieParam(
            const key: string;
            const defValue : string = ''
        ) : string; virtual;

        (*!------------------------------------------------
         * get all cookies params
         *-------------------------------------------------
         * @return list of cookie params
         *------------------------------------------------*)
        function getCookieParams() : IReadOnlyList; virtual;

        (*!------------------------------------------------
         * get request body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParsedBodyParam(
            const key: string;
            const defValue : string = ''
        ) : string; virtual;

        (*!------------------------------------------------
         * get all request body data
         *-------------------------------------------------
         * @return array of parsed body params
         *------------------------------------------------*)
        function getParsedBodyParams() : IReadOnlyList; virtual;

        (*!------------------------------------------------
         * get request uploaded file by name
         *-------------------------------------------------
         * @param string key name of key
         * @return instance of IUploadedFileArray or nil if is not
         *         exists
         *------------------------------------------------*)
        function getUploadedFile(const key: string) : IUploadedFileArray; virtual;

        (*!------------------------------------------------
         * get all uploaded files
         *-------------------------------------------------
         * @return IUploadedFileCollection or nil if no file
         *         upload
         *------------------------------------------------*)
        function getUploadedFiles() : IUploadedFileCollection; virtual;

        (*!------------------------------------------------
         * get CGI environment
         *-------------------------------------------------
         * @return ICGIEnvironment
         *------------------------------------------------*)
        function getEnvironment() : ICGIEnvironment; virtual;

        (*!------------------------------------------------
         * get request query string or body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParam(
            const key: string;
            const defValue : string = ''
        ) : string; virtual;

        (*!------------------------------------------------
         * get all request query string body data
         *-------------------------------------------------
         * @return array of query string and parsed body params
         *------------------------------------------------*)
        function getParams() : IReadOnlyList; virtual;

    end;

implementation

    constructor TFpwebRequest.create(const request : TFPHttpConnectionRequest);
    begin
        fRequest := request;
    end;

    destructor TFpwebRequest.destroy();
    begin
        fRequest := nil;
        inherited destroy();
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TFpwebRequest.headers() : IReadOnlyHeaders;
    begin
        result := fRequest.headers();
    end;

    (*!------------------------------------------------
     * get request URI
     *-------------------------------------------------
     * @return IUri of current request
     *------------------------------------------------*)
    function TFpwebRequest.uri() : IUri;
    begin
        result := fRequest.uri();
    end;

    (*!------------------------------------------------
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TFpwebRequest.getQueryParam(const key: string; const defValue : string = '') : string;
    begin
        result := fRequest.queryFields[key];
    end;

    (*!------------------------------------------------
     * get all request query strings data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TFpwebRequest.getQueryParams() : IReadOnlyList;
    begin
        result := fRequest.QueryFields;
    end;

    (*!------------------------------------------------
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TFpwebRequest.getCookieParam(const key: string; const defValue : string = '') : string;
    begin
        result := fRequest.Cookies(key, defValue);
    end;

    (*!------------------------------------------------
     * get all request cookie data
     *-------------------------------------------------
     * @return list of request cookies parameters
     *------------------------------------------------*)
    function TFpwebRequest.getCookieParams() : IReadOnlyList;
    begin
        result := fActualRequest.getCookieParams();
    end;

    (*!------------------------------------------------
     * get request body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TFpwebRequest.getParsedBodyParam(const key: string; const defValue : string = '') : string;
    begin
        result := fActualRequest.getParsedBodyParam(key, defValue);
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return list of request body parameters
     *------------------------------------------------*)
    function TFpwebRequest.getParsedBodyParams() : IReadOnlyList;
    begin
        result := fActualRequest.getParsedBodyParams();
    end;

    (*!------------------------------------------------
     * get request uploaded file by name
     *-------------------------------------------------
     * @param string key name of key
     * @return instance of IUploadedFileArray or nil if is not
     *         exists
     *------------------------------------------------*)
    function TFpwebRequest.getUploadedFile(const key: string) : IUploadedFileArray;
    begin
        result := fActualRequest.getUploadedFile(key);
    end;

    (*!------------------------------------------------
     * get all uploaded files
     *-------------------------------------------------
     * @return IUploadedFileCollection
     *------------------------------------------------*)
    function TFpwebRequest.getUploadedFiles() : IUploadedFileCollection;
    begin
        result := fActualRequest.getUploadedFiles();
    end;

    (*!------------------------------------------------
     * test if current request is coming from AJAX request
     *-------------------------------------------------
     * @return true if ajax request false otherwise
     *------------------------------------------------*)
    function TFpwebRequest.isXhr() : boolean;
    begin
        result := fRequest.isXhr();
    end;

    (*!------------------------------------------------
     * get request method GET, POST, HEAD, etc
     *-------------------------------------------------
     * @return string request method
     *------------------------------------------------*)
    function TFpwebRequest.getMethod() : string;
    begin
        result := fActualRequest.getMethod();
    end;

    (*!------------------------------------------------
     * get CGI environment
     *-------------------------------------------------
     * @return ICGIEnvironment
     *------------------------------------------------*)
    function TFpwebRequest.getEnvironment() : ICGIEnvironment;
    begin
        result := fActualRequest.getEnvironment();
    end;

    (*!------------------------------------------------
     * get single query param or body param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TFpwebRequest.getParam(const key: string; const defValue : string = '') : string;
    begin
        result := fActualRequest.getParam(key, defValue);
    end;

    (*!------------------------------------------------
     * get all request query strings or body data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TFpwebRequest.getParams() : IReadOnlyList;
    begin
        result := fActualRequest.getParams();
    end;

end.
