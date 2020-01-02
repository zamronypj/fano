{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit JsonFileCacheImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    CacheIntf,
    SerializeableIntf,
    CacheItemIntf,
    HashIntf,
    ClockIntf,
    fpjson;

type

    (*!------------------------------------------------
     * class having capability to manage
     * cache in file json
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TJsonFileCache = class (TInterfacedObject, ICache)
    private
        fReader : IFileReader;
        fHash : IHash;
        fClock : IClock;
        fCacheDirectory : string;

        (*!------------------------------------------------
         * read filename and return as JSON
         *-----------------------------------------------
         * @param fname absolute filename
         * @return JSON object
         *-----------------------------------------------*)
        function readCacheFromFile(const fname : string) : TJsonData;

        (*!------------------------------------------------
         * test if cached item expired
         *-----------------------------------------------
         * @param key
         * @return boolean true if key is expired
         *-----------------------------------------------*)
        function expired(const fname : string) : boolean;
    public
        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param reader class that provide file reading facility
         * @param hash class that provide hashing algorithm
         * @param clock class that provide time query facility
         * @param cacheDir directory where cache will be stored
         *------------------------------------------------
         * cacheDir is assumed to end with directory separator
         * and writeable
         *-----------------------------------------------*)
        constructor create(
            const reader : IFileReader;
            const hash : IHash;
            const clock : IClock;
            const cacheDir : string
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * test if cached item with key is available and not expired
         *-----------------------------------------------
         * @param key
         * @return boolean true if key is set
         *-----------------------------------------------*)
        function has(const key : string) : boolean;

        (*!------------------------------------------------
         * Fetches a value from the cache.
         *-----------------------------------------------
         * @param key
         * @param default value to return if cache item not found
         * @return cached item
         *-----------------------------------------------*)
        function read(const key : string; const defValue : ICacheItem) : ICacheItem;

        (*!------------------------------------------------
         * store a value in cache
         *-----------------------------------------------
         * @param key
         * @param value to store in cache
         * @param ttl time to live in seconds
         * @return true if value is written succefully in cache
         *-----------------------------------------------*)
        function write(const key : string; const value : ISerializeable; const ttl : integer) : boolean;

        (*!------------------------------------------------
         * delete item from cache
         *-----------------------------------------------
         * @param key
         * @return true if item successfully deleted
         *-----------------------------------------------*)
        function delete(const key : string) : boolean;

        (*!------------------------------------------------
         * delte all items from cache
         *-----------------------------------------------
         * @return true if item successfully cleared
         *-----------------------------------------------*)
        function clear(const key : string) : boolean;
    end;

implementation

uses

    SysUtils,
    dateutil;

resourcestring

    sErrDirNotWriteable = 'Directory %s is not readable, writeable or exists';

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param reader class that provide file reading facility
     * @param hash class that provide hashing algorithm
     * @param clock class that provide time query facility
     * @param cacheDir directory where cache will be stored
     *------------------------------------------------
     * cacheDir is assumed to end with directory separator
     * and writeable
     *-----------------------------------------------*)
    constructor TJsonFileCache.create(
        const reader : IFileReader;
        const hash : IHash;
        const clock : IClock;
        const cacheDir : string
    );
    begin
        fReader := reader;
        fHash := hash;
        fClock := clock;
        fCacheDirectory := cacheDir;
        if fpAccess(fCacheDirectory, R_OK or W_OK or F_OK) <> 0 then
        begin
            raise EInOutError.createFmt(sErrDirNotWriteable, [ fCacheDirectory ]);
        end;
    end;

    destructor TJsonFileCache.destroy();
    begin
        fReader := nil;
        fHash := nil;
        fClock := nil;
        inherited destroy();
    end;

    (*!------------------------------------------------
     * read filename and return as JSON
     *-----------------------------------------------
     * @param fname absolute filename
     * @return JSON object
     *-----------------------------------------------*)
    function TJsonFileCache.readCacheFromFile(const fname : string) : TJsonData;
    begin
        result := getJson(fReader.readFile(fname));
    end;

    (*!------------------------------------------------
     * test if cached item expired
     *-----------------------------------------------
     * @param key
     * @return boolean true if key is expired
     *-----------------------------------------------*)
    function TJsonFileCache.expired(const fname : string) : boolean;
    var cacheData : TJSONData;
        expiresTimestamp : int64;
        currTimeStamp : int64;
    begin
        cacheData := readCacheFromFile(fname);
        expiresTimestamp := cacheData.findPath('expires').asInt64;
        currTimeStamp := DateTimeToUnix(fClock.getCurrentTime());
        result := (expiresTimestamp >= currTimeStamp);
    end;

    (*!------------------------------------------------
     * test if cached item with key is available and not expired
     *-----------------------------------------------
     * @param key
     * @return boolean true if key is set
     *-----------------------------------------------*)
    function TJsonFileCache.has(const key : string) : boolean;
    var fname : string;
    begin
        fname := fCacheDirectory + fHash.hash(key);
        if (fileExists(fname)) then
        begin
            if (not expired(fname)) then
            begin
                result := true;
            end else
            begin
                result := false;
            end;
        end else
        begin
            result := false;
        end;
    end;

    (*!------------------------------------------------
     * Fetches a value from the cache.
     *-----------------------------------------------
     * @param key
     * @param default value to return if cache item not found
     * @return cached item
     *-----------------------------------------------*)
    function TJsonFileCache.read(const key : string; const defValue : ICacheItem) : ICacheItem;
    var fname : string;
    begin
        fname := fCacheDirectory + fHash.hash(key);
        if (fileExists(fname)) then
        begin
            if (not expired(fname)) then
            begin
                result := unserialize(fName);
            end else
            begin
                DeleteFile(fName);
                result := defValue;
            end;
        end else
        begin
            result := defValue;
        end;
    end;

    (*!------------------------------------------------
     * store a value in cache
     *-----------------------------------------------
     * @param key
     * @param value to store in cache
     * @param ttl time to live in seconds
     * @return true if value is written succefully in cache
     *-----------------------------------------------*)
    function TJsonFileCache.write(const key : string; const value : ISerializeable; const ttl : integer) : boolean;
    begin

    end;

    (*!------------------------------------------------
     * delete item from cache
     *-----------------------------------------------
     * @param key
     * @return true if item successfully deleted
     *-----------------------------------------------*)
    function TJsonFileCache.delete(const key : string) : boolean;
    begin

    end;

    (*!------------------------------------------------
     * delte all items from cache
     *-----------------------------------------------
     * @return true if item successfully cleared
     *-----------------------------------------------*)
    function TJsonFileCache.clear(const key : string) : boolean;
    begin

    end;
end.
