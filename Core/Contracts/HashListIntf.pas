{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit HashListIntf;

interface

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
        function add(const routeName : string; const routeData : pointer) : integer;
        function find(const routeName : string) : pointer;
    end;

implementation
end.
