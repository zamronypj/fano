unit ConfigImpl;

interface

uses
    fpjson,
    jsonparser,
    DependencyIntf,
    ConfigIntf;

type

    TFanoConfig = class(TInterfacedObject, IAppConfiguration, IDependency)
    private
        json :TJSONData;
    public
        constructor create(const configFile : string);
        destructor destroy(); override;
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
        function isNull(const configName : string) : boolean;
    end;

implementation

uses
    sysutils,
    classes;

    constructor TFanoConfig.create(const configFile : string);
    var fstream : TFileStream;
    begin
        fstream := TFileStream.create(configFile, fmOpenRead);
        try
            json := getJSON(fstream);
        finally
            fstream.free();
        end;
    end;

    destructor TFanoConfig.destroy();
    begin
        inherited destroy();
        json.free();
    end;

    function TFanoConfig.getString(const configName : string) : string;
    begin
       result := json.findPath(configName).asString;
    end;

    function TFanoConfig.getInt(const configName : string) : integer;
    begin
       result := json.findPath(configName).asInteger;
    end;

    function TFanoConfig.isNull(const configName : string) : boolean;
    begin
       result := json.findPath(configName).isNull;
    end;
end.
