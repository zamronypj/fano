unit RouteListImpl;

interface

uses
    contnrs,
    RouteListIntf;

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRouteList = class(TInterfacedObject, IRouteList)
    private
        routes : TFPHashList;
    public
        constructor create();
        destructor destroy(); override;

        function count() : integer;
        function get(const indx : integer) : pointer;
        procedure delete(const indx : integer);
        function add(const routeName : string; const routeData : pointer) : integer;
        function find(const routeName : string) : pointer;
    end;

implementation

    constructor TRouteList.create();
    begin
        routes := TFPHashList.create();
    end;

    destructor TRouteList.destroy();
    begin
        routes.free();
    end;

    function TRouteList.count() : integer;
    begin
        result := routes.count;
    end;

    function TRouteList.get(const indx : integer) : pointer;
    begin
        result := routes.items[indx];
    end;

    procedure TRouteList.delete(const indx : integer);
    begin
        routes.delete(indx);
    end;

    function TRouteList.add(const routeName : string; const routeData : pointer) : integer;
    begin
        result := routes.add(routeName, routeData);
    end;

    function TRouteList.find(const routeName : string) : pointer;
    begin
        result := routes.find(routeName);
    end;
end.
