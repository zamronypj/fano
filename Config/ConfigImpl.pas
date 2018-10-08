unit ConfigImpl;

interface

uses
    DependencyIntf,
    ConfigIntf;

type

    TFanoConfig = class(TInterfacedObject, IAppConfiguration, IDependency)
    private
    public
        constructor create(const configFile : string);
        destructor destroy(); override;
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
    end;

implementation

uses fpjson;

    constructor TFanoConfig.create(const configFile : string);
    begin
    end;

    destructor TFanoConfig.destroy();
    begin
    end;

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
