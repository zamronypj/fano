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

    RequestIntf,
    ReadOnlyListIntf,
    UploadedFileIntf,
    UploadedFileCollectionIntf,
    ReadonlyHeadersIntf,
    EnvironmentIntf,
    UriIntf,
    libmicrohttpd;

type

    (*!------------------------------------------------
     * class having capability as HTTP request from
     * libmicrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TMhdRequestImpl = class(TInterfacedObject, IRequest)
    private
        fMethod : string;
        fHeaders : IReadOnlyHeaders;
        fUri : IUri;
        fQueryParams : IReadOnlyList;
        fCookieParams : IReadOnlyList;
        fParsedBodyParams : IReadOnlyList;
        fUploadedFiles : IUploadedFileCollection;
    public
        constructor create(
            const reqMethod : string;
            const reqUrl : string;
        );
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
         * test if current request is coming from AJAX request
         *-------------------------------------------------
         * @return true if ajax request false otherwise
         *------------------------------------------------*)
        function isXhr() : boolean;
    end;

implementation

    constructor TMhdRequestImpl.create(
        const reqMethod : string;
        const reqHeaders : IReadOnlyHeaders;
        const reqUri : IUri;
        const reqQueryParams : IReadOnlyList;
        const reqCookieParams : IReadOnlyList;
        const reqParsedBodyParams : IReadOnlyList;
        const reqUploadedFiles : IUploadedFileCollection
    );
    begin
        fMethod := reqMethod;
        fHeaders := reqHeaders;
        fUri := reqUri;
        fQueryParams := reqQueryParams;
        fCookieParams := reqCookieParams;
        fParsedBodyParams := reqParsedBodyParams;
        fUploadedFiles := reqUploadedFiles;
    end;

    destructor TMhdRequestImpl.destroy();
    begin
        fHeaders := nil;
        fUri := nil;
        fQueryParams := nil;
        fCookieParams := nil;
        fParsedBodyParams := nil;
        fUploadedFiles := nil;
        inherited destroy();
    end;

    (*!------------------------------------
     * get http headers instance
     *-------------------------------------
     * @return header instance
     *-------------------------------------*)
    function TMhdRequestImpl.headers() : IReadOnlyHeaders;
    begin
        result := fHeaders;
    end;

    (*!------------------------------------------------
     * get request URI
     *-------------------------------------------------
     * @return IUri of current request
     *------------------------------------------------*)
    function TMhdRequestImpl.uri() : IUri;
    begin
        result := fUri;
    end;

    (*!------------------------------------------------
     * get request method GET, POST, HEAD, etc
     *-------------------------------------------------
     * @return string request method
     *------------------------------------------------*)
    function TMhdRequestImpl.getMethod() : string;
    begin
        result := fMethod;
    end;

    (*!------------------------------------------------
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TMhdRequestImpl.getQueryParam(const key: string; const defValue : string = '') : string;
    begin
        result := fQueryParams.
    end;

    (*!------------------------------------------------
     * get all query params
     *-------------------------------------------------
     * @return list of query string params
     *------------------------------------------------*)
    function TMhdRequestImpl.getQueryParams() : IReadOnlyList;
    begin
    end;

    (*!------------------------------------------------
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TMhdRequestImpl.getCookieParam(const key: string; const defValue : string = '') : string;
    begin
    end;

    (*!------------------------------------------------
     * get all cookies params
     *-------------------------------------------------
     * @return list of cookie params
     *------------------------------------------------*)
    function TMhdRequestImpl.getCookieParams() : IReadOnlyList;
    begin
    end;

    (*!------------------------------------------------
     * get request body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TMhdRequestImpl.getParsedBodyParam(const key: string; const defValue : string = '') : string;
    begin
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return array of parsed body params
     *------------------------------------------------*)
    function TMhdRequestImpl.getParsedBodyParams() : IReadOnlyList;
    begin
    end;

    (*!------------------------------------------------
     * get request uploaded file by name
     *-------------------------------------------------
     * @param string key name of key
     * @return instance of IUploadedFileArray or nil if is not
     *         exists
     *------------------------------------------------*)
    function TMhdRequestImpl.getUploadedFile(const key: string) : IUploadedFileArray;
    begin
    end;

    (*!------------------------------------------------
     * get all uploaded files
     *-------------------------------------------------
     * @return IUploadedFileCollection or nil if no file
     *         upload
     *------------------------------------------------*)
    function TMhdRequestImpl.getUploadedFiles() : IUploadedFileCollection;
    begin
    end;

    (*!------------------------------------------------
     * get CGI environment
     *-------------------------------------------------
     * @return ICGIEnvironment
     *------------------------------------------------*)
    function TMhdRequestImpl.getEnvironment() : ICGIEnvironment;
    begin
    end;

    (*!------------------------------------------------
     * get request query string or body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TMhdRequestImpl.getParam(const key: string; const defValue : string = '') : string;
    begin
    end;

    (*!------------------------------------------------
     * get all request query string body data
     *-------------------------------------------------
     * @return array of query string and parsed body params
     *------------------------------------------------*)
    function TMhdRequestImpl.getParams() : IReadOnlyList;
    begin
    end;

    (*!------------------------------------------------
     * test if current request is coming from AJAX request
     *-------------------------------------------------
     * @return true if ajax request false otherwise
     *------------------------------------------------*)
    function TMhdRequestImpl.isXhr() : boolean;
    begin
    end;
end.
