{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit HashListIntf;

interface

{$MODE OBJFPC}
{$H+}

type
    {------------------------------------------------
     interface for any class having capability store hash list
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IHashList = interface
        ['{7EEE23CC-9713-49E2-BE92-CC63BDEA17F3}']
        function count() : integer;
        function get(const indx : integer) : pointer;
        procedure delete(const indx : integer);
        function add(const key : shortstring; const routeData : pointer) : integer;
        function find(const key : shortstring) : pointer;
        function keyOfIndex(const indx : integer) : shortstring;
    end;

implementation
end.
