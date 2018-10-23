{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit JsonStringConfigImpl;

interface
{$H+}

uses
    fpjson,
    jsonparser,
    DependencyIntf,
    ConfigIntf,
    JsonConfigImpl;

type

    (*!------------------------------------------------------------
     * Application configuration class that load data from JSON string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------------------*)
    TJsonStringConfig = class(TJsonConfig, IAppConfiguration, IDependency)
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
