unit ViewParametersImpl;

interface

uses
    classes,
    contnrs,
    ViewParamsIntf;

type
    {------------------------------------------------
     interface for any class having capability as
     view parameters
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TViewParameters = class(TInterfacedObject, IViewParameters)
    private
        keyValueMap : TFPStringHashTable;
        keys : TStringList;
    public
        constructor create();
        destructor destroy(); override;
        function vars() : TStrings;
        function getVar(const varName : string) : string;
        function setVar(const varName : string; const valueData :string) : IViewParameters;
    end;

implementation

    constructor TViewParameters.create();
    begin
        keyValueMap := TFPStringHashTable.create();
        keys := TStringList.create();
    end;

    destructor TViewParameters.destroy();
    begin
        inherited destroy();
        keyValueMap.free();
        keys.free();
    end;

    function TViewParameters.vars() : TStrings;
    begin
        result := keys;
    end;

    function TViewParameters.getVar(const varName : string) : string;
    begin
       result := keyValueMap[varName];
    end;

    function TViewParameters.setVar(
        const varName : string;
        const valueData :string
    ) : IViewParameters;
    begin
        if (keyValueMap[varName] = '') then
        begin
            //not exists
            keyValueMap.add(varName, valueData);
            keys.add(varName);
        end else
        begin
            keyValueMap[varName] := valueData;
        end;;
        result := self;
    end;
end.
