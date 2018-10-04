unit ViewParamsImpl;

interface

uses
    StrHashMap,
    BasicTypes,
    ViewParamsIntf;

type
    {------------------------------------------------
     interface for any class having capability as
     view parameters
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TViewParameters = class(TInterfacedObject, IViewParameters)
    private
        keyValueMap : TStringHashMap;
        keys : TArrayOfStrings;
    public
        function vars() : TArrayOfStrings;
        function getVar(const varName : string) : string;
        function setVar(const varName : string; const value :string) : IViewParameters;
    end;

implementation

    function TViewParameters.vars() : TArrayOfStrings;
    begin
        result := keys;
    end;

    function TViewParameters.getVar(const varName : string) : string;
    begin
       result := keyValueMap.find(varName);
    end;

    function TViewParameters.setVar(
        const varName : string;
        const value :string
    ) : IViewParameters;
    begin
       result := self;
    end;
end.
