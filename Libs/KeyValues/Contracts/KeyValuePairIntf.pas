{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit KeyValuePairIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability key value
     * pair
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IKeyValuePair = interface
        ['{28ECD547-C550-4CEF-8E8B-BFA0B1DF6CEC}']

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
         * @throws EKeyNotFound exception if not set
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
         * get number of keys
         *-----------------------------------------------
         * @return number of keys
         *-----------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get key by index
         *-----------------------------------------------
         * @param index index to use
         * @return key name
         * @throws EKeyNotFound exception if not set
         *-----------------------------------------------*)
        function getKey(const indx : integer) : shortstring;
    end;

implementation
end.
