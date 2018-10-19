{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RouteListImpl;

interface

uses
    RouteListIntf,
    HashListImpl;

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
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
