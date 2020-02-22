{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonRequestImpl;

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
    fpjson,
    HashListImpl;

type

    (*!------------------------------------------------
     * interface for any class having capability as
     * HTTP request
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonRequest = class(TDecoratorRequest)
    private
        fBodyJson : TJsonData;
        fBodyList : THashList;

        procedure buildFlatList(const bodyJson : TJsonData; const bodyList : THashList);
    public

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
        function getParsedBodyParams() : IReadOnlyList; override;

        (*!------------------------------------------------
         * get request query string or body data
         *-------------------------------------------------
         * @param string key name of key
         * @param string defValue default value to use if key
         *               does not exist
         * @return string value
         *------------------------------------------------*)
        function getParam(const key: string; const defValue : string = '') : string; override;

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

    procedure TJsonRequest.buildFlatList(
        const bodyJson : TJsonData;
        const bodyList : THashList;
        const key : string;
    );
    var i : integer;
    begin
        if (bodyJson.count > 0) then
        begin
            for i := 0 to bodyJson.count - 1 do
            begin
                buildFlatList(bodyJson.items[i], bodyList)
            end;
        end else
        begin
        end;
    end;

    constructor TJsonRequest.create(const request : IRequest);
    begin
        inherited create(request);
        try
            fBodyJson := getJSON(fActualRequest.getParsedBodyParam('application/json'));
        except
            fBodyJson := nil;
            raise;
        end;
    end;

    destructor TJsonRequest.destroy();
    begin
        fBodyJson.free();
        inherited destroy();
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
    var data : TJSONData;
    begin
        result := defValue;
        data := fBodyJson.findPath(key);
        if (data <> nil) then
        begin
            if data.count > 0 then
            begin
                //it is data having child just return is as JSON string
                result := data.asJSON;
            end else
            begin
                result := data.asString;
            end;
        end;
    end;

    (*!------------------------------------------------
     * get all request body data
     *-------------------------------------------------
     * @return list of request body parameters
     *------------------------------------------------*)
    function TJsonRequest.getParsedBodyParams() : IReadOnlyList;
    begin
        result := self;
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
        result := inherited getParam(key, defValue);
        if (result = '') then
        begin
            result := getParsedBodyParam(key, defValue);
        end;
    end;

    (*!------------------------------------------------
     * get all request query strings or body data
     *-------------------------------------------------
     * @return list of request query string parameters
     *------------------------------------------------*)
    function TJsonRequest.getParams() : IReadOnlyList;
    begin
        result := self;
    end;

    (*!------------------------------------------------
     * get number of item in list
     *-----------------------------------------------
     * @return number of item in list
     *-----------------------------------------------*)
    function TJsonRequest.count() : integer;
    begin
        result := fBodyList.count;
    end;

    (*!------------------------------------------------
     * get item by index
     *-----------------------------------------------
     * @param indx index of item
     * @return item instance
     *-----------------------------------------------*)
    function TJsonRequest.get(const indx : integer) : pointer;
    begin
        result := fBodyList.get(indx);
    end;

    (*!------------------------------------------------
     * find by its key name
     *-----------------------------------------------
     * @param aKey name to use to find item
     * @return item instance
     *-----------------------------------------------*)
    function TJsonRequest.find(const aKey : shortstring) : pointer;
    var adata : TJsonData;
    begin
        adata := fBodyJson.findPath(aKey);
        if (adata <> nil) then
        begin
            result := pointer(data);
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
        result := fBodyList.keyOfIndex(index);
    end;

    (*!------------------------------------------------
     * get index by key name
     *-----------------------------------------------
     * @param aKey name
     * @return index of key
     *-----------------------------------------------*)
    function TJsonRequest.indexOf(const aKey : shortstring) : integer;
    begin
        result := fBodyList.indexOf(aKey);
    end;

end.
