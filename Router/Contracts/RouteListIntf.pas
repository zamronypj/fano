unit RouteListIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRouteList = interface
        ['{0BE04022-B3E7-4AE9-83F8-829D07F7EB83}']
        function count() : integer;
        function get(const indx : integer) : pointer;
        procedure delete(const indx : integer);
        function add(const routeName : string; const routeData : pointer) : integer;
        function find(const routeName : string) : pointer;
    end;

implementation
end.
