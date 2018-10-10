unit ConfigImpl;

interface
{$H+}

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
        function getString(const configName : string; const defaultValue : string = '') : string;
        function getInt(const configName : string; const defaultValue : integer = 0) : integer;
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

    function TFanoConfig.getString(const configName : string; const defaultValue : string = '') : string;
    var jsonData : TJSONData;
    begin
        jsonData := json.findPath(configName);
        if (jsonData = nil) then
        begin
            result := defaultValue;
        end else
        begin
            result := jsonData.asString;
        end;
    end;

    function TFanoConfig.getInt(const configName : string; const defaultValue : integer = 0) : integer;
    var jsonData : TJSONData;
    begin
        jsonData := json.findPath(configName);
        if (jsonData = nil) then
        begin
            result := defaultValue;
        end else
        begin
            result := jsonData.asInteger;
        end;
    end;

end.
