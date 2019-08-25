{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ListIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability store
     * list of item
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IList = interface
        ['{7EEE23CC-9713-49E2-BE92-CC63BDEA17F3}']

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
         * delete item by index
         *-----------------------------------------------
         * @param indx index of item
         *-----------------------------------------------
         * implementor is free to decide whether delete
         * item in list only or also free item memory
         *-----------------------------------------------*)
        procedure delete(const indx : integer);

        (*!------------------------------------------------
         * add item and associate it with key name
         *-----------------------------------------------
         * @param key name to use to associate item
         * @param item item to be added
         * @return index of item
         *-----------------------------------------------*)
        function add(const key : shortstring; const item : pointer) : integer;

        (*!------------------------------------------------
         * find by its key name
         *-----------------------------------------------
         * @param key name to use to find item
         * @return item instance
         *-----------------------------------------------*)
        function find(const key : shortstring) : pointer;

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
         * @param key name
         * @return index of key
         *-----------------------------------------------*)
        function indexOf(const key : shortstring) : integer;
    end;

implementation
end.
