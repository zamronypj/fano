unit ViewParamsImpl;

interface

uses
    ViewParamsIntf;

type
    {------------------------------------------------
     interface for any class having capability as
     view parameters
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TViewParameters = class(TInterfacedObject, IViewParameters)
    public
        function getVar(const varName : string) : string;
    end;

implementation
    function TViewParameters.getVar(const varName : string) : string;
    begin
       result := '';
    end;
end.
