{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CacheIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    SerializeableIntf,
    CacheItemIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to manage
     * cache
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ICache = interface
        ['{9264B294-2642-49AB-832F-5E5E826FE4DF}']

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

end.
