{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RedisCacheImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    CacheIntf,
    SerializeableIntf,
    CacheItemIntf;

type

    (*!------------------------------------------------
     * class having capability to manage
     * cache in Redis
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TRedisCache = class (TInterfacedObject, ICache)
    public

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

    (*!------------------------------------------------
     * test if cached item with key is available and not expired
     *-----------------------------------------------
     * @param key
     * @return boolean true if key is set
     *-----------------------------------------------*)
    function TRedisCache.has(const key : string) : boolean;
    begin

    end;

    (*!------------------------------------------------
     * Fetches a value from the cache.
     *-----------------------------------------------
     * @param key
     * @param default value to return if cache item not found
     * @return cached item
     *-----------------------------------------------*)
    function TRedisCache.read(const key : string; const defValue : ICacheItem) : ICacheItem;
    begin

    end;

    (*!------------------------------------------------
     * store a value in cache
     *-----------------------------------------------
     * @param key
     * @param value to store in cache
     * @param ttl time to live in seconds
     * @return true if value is written succefully in cache
     *-----------------------------------------------*)
    function TRedisCache.write(const key : string; const value : ISerializeable; const ttl : integer) : boolean;
    begin

    end;

    (*!------------------------------------------------
     * delete item from cache
     *-----------------------------------------------
     * @param key
     * @return true if item successfully deleted
     *-----------------------------------------------*)
    function TRedisCache.delete(const key : string) : boolean;
    begin

    end;

    (*!------------------------------------------------
     * delte all items from cache
     *-----------------------------------------------
     * @return true if item successfully cleared
     *-----------------------------------------------*)
    function TRedisCache.clear(const key : string) : boolean;
    begin

    end;
end.
