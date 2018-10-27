{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RouteListImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    RouteListIntf,
    HashListImpl;

type

    (*!------------------------------------------------
     * class that store list of routes patterns and its
     * associated data and match uri to retrieve matched
     * patterns and its data.
     *
     * This class does not support any variable placeholder
     * and match route exactly as they registered
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouteList = class(THashList, IRouteList)
    public
        function match(const requestUri : shortstring) : pointer;
    end;

implementation

    function TRouteList.match(const requestUri : string) : pointer;
    begin
        result := find(requestUri);
    end;
end.
