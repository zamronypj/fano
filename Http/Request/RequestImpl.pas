{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RequestImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    EnvironmentIntf,
    RequestIntf,
    HashListIntf,
    KeyValueTypes;

type

    (*!------------------------------------------------
     * basic class having capability as
     * HTTP request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRequest = class(TInterfacedObject, IRequest)
    private
        webEnvironment : ICGIEnvironment;
        queryParams : IHashList;
        cookieParams : IHashList;
        bodyParams : IHashList;

        function getContentLength(const env : ICGIEnvironment) : integer;

        procedure clearParams(const params : IHashList);

        procedure initParamsFromString(
            const data : string;
            const hashInst : IHashList
        );

        procedure initPostBodyParamsFromStdInput(
            const env : ICGIEnvironment;
            const body : IHashList
        );

        procedure initBodyParamsFromStdInput(
            const env : ICGIEnvironment;
            const body : IHashList
        );

        procedure initQueryParamsFromEnvironment(
            const env : ICGIEnvironment;
            const query : IHashList
        );

        procedure initCookieParamsFromEnvironment(
            const env : ICGIEnvironment;
            const cookies : IHashList
        );

        procedure initParamsFromEnvironment(
            const env : ICGIEnvironment;
            const query : IHashList;
            const cookies : IHashList;
            const body : IHashList
        );

        (*!------------------------------------------------
         * get single query param value by its name
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParam(
            const src :IHashList;
            const key: string;
            const defValue : string = ''
        ) : string;

    public
        constructor create(
            const env : ICGIEnvironment;
            const query : IHashList;
            const cookies : IHashList;
            const body : IHashList
        );
        destructor destroy(); override;

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
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getQueryParams() : IHashList;

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
         * get all query params
         *-------------------------------------------------
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getCookieParams() : IHashList;

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
         * @return array of TKeyValue
         *------------------------------------------------*)
        function getParsedBodyParams() : IHashList;

        (*!------------------------------------------------
         * test if current request is comming from AJAX request
         *-------------------------------------------------
         * @return true if ajax request
         *------------------------------------------------*)
        function isXhr() : boolean;
    end;

implementation

uses

    sysutils,
    UrlHelpersImpl,
    EInvalidRequestImpl;

resourcestring

    sErrInvalidContentLength = 'Invalid content length';

    constructor TRequest.create(
        const env : ICGIEnvironment;
        const query : IHashList;
        const cookies : IHashList;
        const body : IHashList
    );
    begin
        webEnvironment := env;
        queryParams := query;
        cookieParams := cookies;
        bodyParams := body;
        initParamsFromEnvironment(
            webEnvironment,
            queryParams,
            cookieParams,
            bodyParams
        );

    end;

    destructor TRequest.destroy();
    begin
        inherited destroy();
        clearParams(queryParams);
        clearParams(cookieParams);
        clearParams(bodyParams);
        webEnvironment := nil;
        queryParams := nil;
        cookieParams := nil;
        bodyParams := nil;
    end;

    procedure TRequest.clearParams(const params : IHashList);
    var i, len : integer;
        param : PKeyValue;
    begin
        len := params.count();
        for i:= len-1 downto 0 do
        begin
            param := params.get(i);
            dispose(param);
            params.delete(i);
        end;
    end;

    procedure TRequest.initParamsFromString(
        const data : string;
        const hashInst : IHashList
    );
    var arrOfQryStr, keyvalue : TStringArray;
        i, len, lenKeyValue : integer;
        param : PKeyValue;
    begin
        arrOfQryStr := data.split(['&']);
        len := length(arrOfQryStr);
        for i:= 0 to len-1 do
        begin
            keyvalue := arrOfQryStr[i].split('=');
            lenKeyValue := length(keyvalue);
            if (lenKeyValue = 2) then
            begin
                new(param);
                param^.key := keyvalue[0];
                param^.value := (keyvalue[1]).urlDecode();
                hashInst.add(param^.key, param);
            end;
        end;
    end;

    procedure TRequest.initQueryParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IHashList
    );
    begin
        initParamsFromString(env.queryString(), query);
    end;

    procedure TRequest.initCookieParamsFromEnvironment(
        const env : ICGIEnvironment;
        const cookies : IHashList
    );
    begin
        initParamsFromString(env.httpCookie(), cookies);
    end;

    function TRequest.getContentLength(const env : ICGIEnvironment) : integer;
    begin
        try
            result := strToInt(env.contentLength());
        except
            on e:EConvertError do
            begin
                raise EInvalidRequest.create(sErrInvalidContentLength);
            end;
        end;
    end;

    procedure TRequest.initPostBodyParamsFromStdInput(
        const env : ICGIEnvironment;
        const body : IHashList
    );
    var contentLength, ctr : integer;
        contentType, bodyStr : string;
        ch : char;
        param : PKeyValue;
    begin
        //read STDIN
        contentLength := getContentLength(env);
        ctr := 0;
        setLength(bodyStr, contentLength);
        while (ctr < contentLength) do
        begin
            read(ch);
            bodyStr[ctr+1] := ch;
            inc(ctr);
        end;

        contentType := env.contentType();
        if ((contentType = 'application/x-www-form-urlencoded') or
            (contentType = 'multipart/form-data')) then
        begin
            initParamsFromString(bodyStr, body);
        end else
        begin
            //if POST but different contentType save it as it is
            //with its contentType as key
            new(param);
            param^.key := contentType;
            param^.value := bodyStr;
            body.add(param^.key, param);
        end;
    end;

    procedure TRequest.initBodyParamsFromStdInput(
        const env : ICGIEnvironment;
        const body : IHashList
    );
    var method : string;
    begin
        method := env.requestMethod();
        if (method = 'POST') then
        begin
            initPostBodyParamsFromStdInput(env, body);
        end;
    end;

    procedure TRequest.initParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IHashList;
        const cookies : IHashList;
        const body : IHashList
    );
    begin
        initQueryParamsFromEnvironment(env, query);
        initCookieParamsFromEnvironment(env, cookies);
        initBodyParamsFromStdInput(env, bodyParams);
    end;

    (*!------------------------------------------------
     * get single param value by its name
     *-------------------------------------------------
     * @param IHashList src hash list instance
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getParam(
        const src : IHashList;
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
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getQueryParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(queryParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request query strings data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TRequest.getQueryParams() : IHashList;
    begin
        result := queryParams;
    end;

    (*!------------------------------------------------
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getCookieParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(cookieParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request cookie data
     *-------------------------------------------------
     * @return list of request cookies parameters
     *------------------------------------------------*)
    function TRequest.getCookieParams() : IHashList;
    begin
        result := cookieParams;
    end;

    (*!------------------------------------------------
     * get request body data
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getParsedBodyParam(const key: string; const defValue : string = '') : string;
    begin
        result := getParam(bodyParams, key, defValue);
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return list of request body parameters
     *------------------------------------------------*)
    function TRequest.getParsedBodyParams() : IHashList;
    begin
        result := bodyParams;
    end;

    (*!------------------------------------------------
     * test if current request is coming from AJAX request
     *-------------------------------------------------
     * @return true if ajax request false otherwise
     *------------------------------------------------*)
    function TRequest.isXhr() : boolean;
    begin
        result := (webEnvironment.env('HTTP_X_REQUESTED_WITH') = 'XMLHttpRequest');
    end;
end.
