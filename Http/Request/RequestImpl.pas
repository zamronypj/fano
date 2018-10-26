unit RequestImpl;

interface
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

        procedure clearParams(const params : IHashList);

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
            const cookies : IHashList
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

        (*!------------------------------------------------
         * get all params
         *-------------------------------------------------
         * @return array of TQueryParam
         *------------------------------------------------*)
        function getParams(const src : IHashList) : TArrayOfKeyValue;
    public
        constructor create(
            const env : ICGIEnvironment;
            const query : IHashList;
            const cookies : IHashList
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
         * @return array of TQueryParam
         *------------------------------------------------*)
        function getQueryParams() : TArrayOfKeyValue;

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
         * @return array of TQueryParam
         *------------------------------------------------*)
        function getCookieParams() : TArrayOfKeyValue;
    end;

implementation

uses

    sysutils;

    constructor TRequest.create(
        const env : ICGIEnvironment;
        const query : IHashList;
        const cookies : IHashList
    );
    begin
        webEnvironment := env;
        queryParams := query;
        cookieParams := cookies;
        initParamsFromEnvironment(webEnvironment, queryParams, cookieParams);
    end;

    destructor TRequest.destroy();
    begin
        inherited destroy();
        clearParams(queryParams);
        clearParams(cookieParams);
        webEnvironment := nil;
        queryParams := nil;
        cookieParams := nil;
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

    procedure TRequest.initQueryParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IHashList
    );
    var arrOfQryStr, keyvalue : TStringArray;
        i, len, lenKeyValue : integer;
        param : PKeyValue;
    begin
        arrOfQryStr := env.queryString().split(['&']);
        len := length(arrOfQryStr);
        for i:= 0 to len-1 do
        begin
            keyvalue := arrOfQryStr[i].split('=');
            lenKeyValue := length(keyvalue);
            if (lenKeyValue = 2) then
            begin
                new(param);
                param^.key := keyvalue[0];
                param^.value := keyvalue[1];
                query.add(param^.key, param);
            end;
        end;
    end;

    procedure TRequest.initCookieParamsFromEnvironment(
        const env : ICGIEnvironment;
        const cookies : IHashList
    );
    var arrOfQryStr, keyvalue : TStringArray;
        i, len, lenKeyValue : integer;
        param : PKeyValue;
    begin
        arrOfQryStr := env.httpCookie().split(['&']);
        len := length(arrOfQryStr);
        for i:= 0 to len-1 do
        begin
            keyvalue := arrOfQryStr[i].split('=');
            lenKeyValue := length(keyvalue);
            if (lenKeyValue = 2) then
            begin
                new(param);
                param^.key := keyvalue[0];
                param^.value := keyvalue[1];
                cookies.add(param^.key, param);
            end;
        end;
    end;

    procedure TRequest.initParamsFromEnvironment(
        const env : ICGIEnvironment;
        const query : IHashList;
        const cookies : IHashList
    );
    begin
        initQueryParamsFromEnvironment(env, query);
        initCookieParamsFromEnvironment(env, cookies);
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
     * get all params
     *-------------------------------------------------
     * @return array of TKeyValue
     *------------------------------------------------*)
    function TRequest.getParams(const src : IHashList) : TArrayOfKeyValue;
    var i, len : integer;
        qry : PKeyValue;
    begin
        len := src.count();
        setLength(result, len);
        for i := 0 to len-1 do
        begin
            qry := src.get(i);
            result[i] := qry^;
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
     * get single query param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getQueryParams() : TArrayOfKeyValue;
    begin
        result := getParams(queryParams);
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
     * get single cookie param value by its name
     *-------------------------------------------------
     * @param string key name of key
     * @param string defValue default value to use if key
     *               does not exist
     * @return string value
     *------------------------------------------------*)
    function TRequest.getCookieParams() : TArrayOfKeyValue;
    begin
        result := getParams(cookieParams);
    end;
end.
