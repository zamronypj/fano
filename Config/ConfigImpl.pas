{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit ConfigImpl;

interface
{$H+}

uses
    fpjson,
    jsonparser,
    DependencyIntf,
    ConfigIntf;

type

    TConfig = class(TInterfacedObject, IAppConfiguration, IDependency)
    protected
        json :TJSONData;
        function buildJsonData() : TJSONData; virtual; abstract;
    public
        constructor create();
        destructor destroy(); override;
        function getString(const configName : string; const defaultValue : string = '') : string;
        function getInt(const configName : string; const defaultValue : integer = 0) : integer;
    end;

implementation

uses
    sysutils,
    classes;

    constructor TConfig.create();
    begin
        json := buildJsonData();
    end;

    destructor TConfig.destroy();
    begin
        inherited destroy();
        json.free();
    end;

    function TConfig.getString(const configName : string; const defaultValue : string = '') : string;
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

    function TConfig.getInt(const configName : string; const defaultValue : integer = 0) : integer;
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
