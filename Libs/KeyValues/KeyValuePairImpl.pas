{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit KeyValuePairImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    KeyValueMapImpl,
    KeyValuePairIntf,
    SerializeableIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic class having capability to store key value
     * pair that implements IKeyValuePair
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TKeyValuePair = class(TinjectableObject, IKeyValuePair, ISerializeable)
    private
        keyValueMap : TKeyValueMap;

        (*!------------------------------------------------
         * serialize key value if not empty
         *-----------------------------------------------
         * Note :
         * This turn key0=value0, key1=value=1,.. into
         * string `key0=value0&key1=value=1&..`
         *-----------------------------------------------
         * @return serialized string
         *-----------------------------------------------*)
        function serializeIfNotEmpty(const itemSize : integer) : string;
    public

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------*)
        constructor create();

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * set key value pair
         *-----------------------------------------------
         * @param key name to use
         * @param val value to use
         * @return current instance
         *-----------------------------------------------*)
        function setValue(const key : shortstring; const val : string) : IKeyValuePair;

        (*!------------------------------------------------
         * get value by key
         *-----------------------------------------------
         * @param key name to use
         * @return value
         *-----------------------------------------------*)
        function getValue(const key : shortstring) : string;

        (*!------------------------------------------------
         * test if key is set
         *-----------------------------------------------
         * @param key name to use
         * @return boolean true if key is set otherwise false
         *-----------------------------------------------*)
        function has(const key : shortstring) : boolean;

        (*!------------------------------------------------
         * unset key
         *-----------------------------------------------
         * @param key name to use
         * @return current instance
         * @throws EKeyNotFound exception if not set
         *-----------------------------------------------*)
        function unset(const key : shortstring) : IKeyValuePair;

        (*!------------------------------------------------
         * serialize key value
         *-----------------------------------------------
         * Note :
         * This turn key0=value0, key1=value=1,.. into
         * string `key0=value0&key1=value=1&..`
         *-----------------------------------------------
         * @return serialized string
         *-----------------------------------------------*)
        function serialize() : string;
    end;

implementation

uses

    UrlHelpersImpl;

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------*)
    constructor TKeyValuePair.create();
    begin
        keyValueMap := TKeyValueMap.create();
        keyValueMap.sorted := true;
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TKeyValuePair.destroy();
    begin
        inherited destroy();
        keyValueMap.free();
    end;

    (*!------------------------------------------------
     * set key value pair
     *-----------------------------------------------
     * @param key name to use
     * @param val value to use
     * @return current instance
     *-----------------------------------------------*)
    function TKeyValuePair.setValue(const key : shortstring; const val : string) : IKeyValuePair;
    begin
        keyValueMap.AddOrSetData(key, val);
        result := self;
    end;

    (*!------------------------------------------------
     * get value by key
     *-----------------------------------------------
     * @param key name to use
     * @return value
     * @throws EKeyNotFound exception if not set
     *-----------------------------------------------*)
    function TKeyValuePair.getValue(const key : shortstring) : string;
    begin
        result := keyValueMap[key];
    end;

    (*!------------------------------------------------
     * test if key is set
     *-----------------------------------------------
     * @param key name to use
     * @return boolean true if key is set otherwise false
     *-----------------------------------------------*)
    function TKeyValuePair.has(const key : shortstring) : boolean;
    var foundIndex : integer;
    begin
        result := keyValueMap.find(key, foundIndex);
    end;

    (*!------------------------------------------------
     * unset key
     *-----------------------------------------------
     * @param key name to use
     * @return current instance
     * @throws EKeyNotFound exception if not set
     *-----------------------------------------------*)
    function TKeyValuePair.unset(const key : shortstring) : IKeyValuePair;
    begin
        keyValueMap.remove(key);
        result := self;
    end;

    (*!------------------------------------------------
     * serialize key value if not empty
     *-----------------------------------------------
     * Note :
     * This turn key0=value0, key1=value=1,.. into
     * string `key0=value0&key1=value=1&..`
     *-----------------------------------------------
     * @return serialized string
     *-----------------------------------------------*)
    function TKeyValuePair.serializeIfNotEmpty(const itemSize : integer) : string;
    var indx : integer;
        key : shortstring;
        val, urlEncodeKey, urlEncodeVal : string;
    begin
        result := '';
        for indx := 0 to itemSize-2 do
        begin
            key := keyValueMap.keys[indx];
            val := keyValueMap.data[indx];
            urlEncodeKey := key.urlEncode();
            urlEncodeVal := val.urlEncode();
            result := result + urlEncodeKey + '=' + urlEncodeVal + '&';
        end;
        key := keyValueMap.keys[itemSize-1];
        val := keyValueMap.data[itemSize-1];
        urlEncodeKey := key.urlEncode();
        urlEncodeVal := val.urlEncode();
        result := result + urlEncodeKey + '=' + urlEncodeVal;
    end;

    (*!------------------------------------------------
     * serialize key value
     *-----------------------------------------------
     * Note :
     * This turn key0=value0, key1=value=1,.. into
     * string `key0=value0&key1=value=1&..`
     *-----------------------------------------------
     * @return serialized string
     *-----------------------------------------------*)
    function TKeyValuePair.serialize() : string;
    var itemSize : integer;
    begin
        result := '';
        itemSize := keyValueMap.ItemSize;
        if (itemSize > 0) then
        begin
            result := serializeIfNotEmpty(itemSize);
        end;
    end;
end.
