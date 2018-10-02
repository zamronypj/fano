unit ConfigImpl;

interface

uses
   ConfigIntf;

type

    TFanoConfig = class(TInterfacedObject, IWebConfiguration)
    private
    public
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
    end;

implementation

    function TFanoConfig.getString(const configName : string) : string;
    begin
       //TODO:
       result := '';
    end;

    function TFanoConfig.getInt(const configName : string) : integer;
    begin
       //TODO:
       result := 0;
    end;
end.
