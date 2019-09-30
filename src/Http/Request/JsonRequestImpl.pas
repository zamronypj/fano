{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RequestIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    AjaxAwareIntf,
    ReadOnlyListIntf,
    UploadedFileIntf,
    UploadedFileCollectionIntf,
    ReadonlyHeadersIntf,
    EnvironmentIntf,
    UriIntf,
    fpjson;

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * HTTP request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonRequest = class(TInterfaceObject, IRequest, IReadOnlyList)
    private
        fActualRequest : IRequest;
        fBodyJson : TJsonData;
        fBodyParams : IReadOnlyList;
        fQueryBodyParams : IReadOnlyList;

        function getSingleParam(
            const src : IReadOnlyList;
            const key: string;
            const defValue : string = ''
        ) : string;
    public
        constructor create(const request : IRequest);
        destructor destroy(); override;

        (*!------------------------------------
         * get http headers instance
         *-------------------------------------
         * @return header instance
         *-------------------------------------*)
        function headers() : IReadOnlyHeaders;

        (*!------------------------------------------------
         * get request URI
         *-------------------------------------------------
         * @return IUri of current request
         *------------------------------------------------*)
        function uri() : IUri;

        (*!------------------------------------------------
         * get request method GET, POST, HEAD, etc
         *-------------------------------------------------
         * @return string request method
         *------------------------------------------------*)
        function getMethod() : string;

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getQueryParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all query params
         *-------------------------------------------------
         * @return list of query string params
         *------------------------------------------------*)
        function getQueryParams() : IReadOnlyList;

        (*!------------------------------------------------
         * get single cookie param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getCookieParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all cookies params
         *-------------------------------------------------
         * @return list of cookie params
         *------------------------------------------------*)
        function getCookieParams() : IReadOnlyList;

        (*!------------------------------------------------
         * get request body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParsedBodyParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all request body data
         *-------------------------------------------------
         * @return array of parsed body params
         *------------------------------------------------*)
        function getParsedBodyParams() : IReadOnlyList;

        (*!------------------------------------------------
         * get request uploaded file by name
         *-------------------------------------------------
         * @param string key name of key
         * @return instance of IUploadedFileArray or nil if is not
         *         exists
         *------------------------------------------------*)
        function getUploadedFile(const key: string) : IUploadedFileArray;

        (*!------------------------------------------------
         * get all uploaded files
         *-------------------------------------------------
         * @return IUploadedFileCollection or nil if no file
         *         upload
         *------------------------------------------------*)
        function getUploadedFiles() : IUploadedFileCollection;

        (*!------------------------------------------------
         * get CGI environment
         *-------------------------------------------------
         * @return ICGIEnvironment
         *------------------------------------------------*)
        function getEnvironment() : ICGIEnvironment;

        (*!------------------------------------------------
         * get request query string or body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParam(const key: string; const defValue : string = '') : string;

        (*!------------------------------------------------
         * get all request query string body data
         *-------------------------------------------------
         * @return array of query string and parsed body params
         *------------------------------------------------*)
        function getParams() : IReadOnlyList;

        (*!------------------------------------------------
         * get number of item in list
         *-----------------------------------------------
         * @return number of item in list
         *-----------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get item by index
         *-----------------------------------------------
         * @param indx index of item
         * @return item instance
         *-----------------------------------------------*)
        function get(const indx : integer) : pointer;

        (*!------------------------------------------------
         * find by its key name
         *-----------------------------------------------
         * @param aKey name to use to find item
         * @return item instance
         *-----------------------------------------------*)
        function find(const aKey : shortstring) : pointer;

        (*!------------------------------------------------
         * get key name by using its index
         *-----------------------------------------------
         * @param indx index to find
         * @return key name
         *-----------------------------------------------*)
        function keyOfIndex(const indx : integer) : shortstring;

        (*!------------------------------------------------
         * get index by key name
         *-----------------------------------------------
         * @param aKey name
         * @return index of key
         *-----------------------------------------------*)
        function indexOf(const aKey : shortstring) : integer;
    end;

implementation

uses

    KeyValueTypes,
    jsonparser;

    constructor TJsonRequest.create(const request : IRequest);
    var abody : string;
    begin
        fActualRequest := request;
        abody := fActualRequest.getParsedBodyParam('application/json');
        if (abody <> '') then
        begin
            fBodyJson := getJSON(abody);
            //combine parsed body params of actual request with ourselves
            fBodyParams := TCompositeList.create(
                self,
                fActualRequest.getParsedBodyParams(),
            );
            fQueryBodyParams := TCompositeList.create(
                fActualRequest.getQueryParams(),
                fBodyParams
            );
        end else
        begin
            fBodyJson := nil;
        end;
    end;

    destructor TJsonRequest.destroy();
    begin
        fActualRequest := nil;
        fBodyParams := nil;
        fQueryBodyParams := nil;
        fBodyJson.free();
        inherited destroy();
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TJsonRequest.headers() : IReadOnlyHeaders;
    begin
        result := fActualRequest.headers();
    end;

    (*!------------------------------------------------
     * get request URI
     *-------------------------------------------------
     * @return IUri of current request
     *------------------------------------------------*)
    function TJsonRequest.uri() : IUri;
    begin
        result := fActualRequest.uri();
    end;

    (*!------------------------------------------------
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TJsonRequest.getQueryParam(const key: string; const defValue : string = '') : string;
    begin
        result := fActualRequest.getQueryParam(key, defValue);
    end;

    (*!------------------------------------------------
     * get all request query strings data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TJsonRequest.getQueryParams() : IReadOnlyList;
    begin
        result := fActualRequest.getQueryParams();
    end;

    (*!------------------------------------------------
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TJsonRequest.getCookieParam(const key: string; const defValue : string = '') : string;
    begin
        result := fActualRequest.getCookieParam(key, defValue);
    end;

    (*!------------------------------------------------
     * get all request cookie data
     *-------------------------------------------------
     * @return list of request cookies parameters
     *------------------------------------------------*)
    function TJsonRequest.getCookieParams() : IReadOnlyList;
    begin
        result := fActualRequest.getCookieParams();
    end;

    (*!------------------------------------------------
     * get single param value by its name
     *-------------------------------------------------
     * @param IList src hash list instance
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TJsonRequest.getSingleParam(
        const src : IReadOnlyList;
        const key: string;
        const defValue : string = ''
    ) : string;
    var qry : PKeyValue;
    begin
        qry := src.find(key);
        if (qry = nil) then
        begin
            result := defValue;
        end else
        begin
            result := qry^.value;
        end;
    end;


    (*!------------------------------------------------
     * get request body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TJsonRequest.getParsedBodyParam(const key: string; const defValue : string = '') : string;
    begin
        result := getSingleParam(fBodyParams);
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return list of request body parameters
     *------------------------------------------------*)
    function TJsonRequest.getParsedBodyParams() : IReadOnlyList;
    begin
        result := fBodyParams;
    end;

    (*!------------------------------------------------
     * get request uploaded file by name
     *-------------------------------------------------
     * @param string key name of key
     * @return instance of IUploadedFileArray or nil if is not
     *         exists
     *------------------------------------------------*)
    function TJsonRequest.getUploadedFile(const key: string) : IUploadedFileArray;
    begin
        result := fActualRequest.getUploadedFile(key);
    end;

    (*!------------------------------------------------
     * get all uploaded files
     *-------------------------------------------------
     * @return IUploadedFileCollection
     *------------------------------------------------*)
    function TJsonRequest.getUploadedFiles() : IUploadedFileCollection;
    begin
        result := fActualRequest.getUploadedFiles();
    end;

    (*!------------------------------------------------
     * test if current request is coming from AJAX request
     *-------------------------------------------------
     * @return true if ajax request false otherwise
     *------------------------------------------------*)
    function TJsonRequest.isXhr() : boolean;
    begin
        result := fActualRequest.isXhr();
    end;

    (*!------------------------------------------------
     * get request method GET, POST, HEAD, etc
     *-------------------------------------------------
     * @return string request method
     *------------------------------------------------*)
    function TJsonRequest.getMethod() : string;
    begin
        result := getEnvironment().requestMethod();
    end;

    (*!------------------------------------------------
     * get CGI environment
     *-------------------------------------------------
     * @return ICGIEnvironment
     *------------------------------------------------*)
    function TJsonRequest.getEnvironment() : ICGIEnvironment;
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
    function TJsonRequest.getParam(const key: string; const defValue : string = '') : string;
    begin
        result := getSingleParam(fQueryBodyParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request query strings or body data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TJsonRequest.getParams() : IReadOnlyList;
    begin
        result := fQueryBodyParams;
    end;

    (*!------------------------------------------------
     * get number of item in list
     *-----------------------------------------------
     * @return number of item in list
     *-----------------------------------------------*)
    function TJsonRequest.count() : integer;
    begin
        result := fBodyJson.count;
    end;

    (*!------------------------------------------------
     * get item by index
     *-----------------------------------------------
     * @param indx index of item
     * @return item instance
     *-----------------------------------------------*)
    function TJsonRequest.get(const indx : integer) : pointer;
    var
    begin
        result := pointer(fBodyJson.items[indx]);
    end;

    (*!------------------------------------------------
     * find by its key name
     *-----------------------------------------------
     * @param aKey name to use to find item
     * @return item instance
     *-----------------------------------------------*)
    function TJsonRequest.find(const aKey : shortstring) : pointer;
    var keyvalue : PKeyValue;
        adata := TJsonData;
    begin
        adata := fBodyJson.findPath(aKey);
        if (adata <> nil) then
        begin
            akeyvalue.key := akey;
            akeyvalue.value := data.asString;
        end else
        begin
            result := nil;
        end;
    end;

    (*!------------------------------------------------
     * get key name by using its index
     *-----------------------------------------------
     * @param indx index to find
     * @return key name
     *-----------------------------------------------*)
    function TJsonRequest.keyOfIndex(const indx : integer) : shortstring;
    begin
    end;

    (*!------------------------------------------------
     * get index by key name
     *-----------------------------------------------
     * @param aKey name
     * @return index of key
     *-----------------------------------------------*)
    function TJsonRequest.indexOf(const aKey : shortstring) : integer;
    begin

    end;

end.
