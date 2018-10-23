unit ConfigStrImpl;

interface
{$H+}

uses
    fpjson,
    jsonparser,
    DependencyIntf,
    ConfigIntf,
    ConfigImpl;

type

    TJsonStringConfig = class(TConfig, IAppConfiguration, IDependency)
    private
        jsonConfigStr : string;
    protected
        function buildJsonData() : TJSONData; override;
    public
        constructor create(const configStr : string);
    end;

implementation

uses
    sysutils,
    classes;

    function TJsonStringConfig.buildJsonData() : TJSONData;
    begin
        result := getJSON(jsonConfigStr);
    end;

    constructor TJsonStringConfig.create(const configStr : string);
    begin
        jsonConfigStr := configStr;
        //must be called after we set jsonConfigStr
        inherited create();
    end;

end.
