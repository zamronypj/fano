unit HashListImpl;

interface

uses
    contnrs,
    HashListIntf;

type
    {------------------------------------------------
     interface for any class having capability to store
     hash list
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    THashList = class(TInterfacedObject, IHashList)
    private
        hashes : TFPHashList;
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

    constructor THashList.create();
    begin
        hashes := TFPHashList.create();
    end;

    destructor THashList.destroy();
    begin
        hashes.free();
    end;

    function THashList.count() : integer;
    begin
        result := hashes.count;
    end;

    function THashList.get(const indx : integer) : pointer;
    begin
        result := hashes.items[indx];
    end;

    procedure THashList.delete(const indx : integer);
    begin
        hashes.delete(indx);
    end;

    function THashList.add(const routeName : string; const routeData : pointer) : integer;
    begin
        result := hashes.add(routeName, routeData);
    end;

    function THashList.find(const routeName : string) : pointer;
    begin
        result := hashes.find(routeName);
    end;
end.
