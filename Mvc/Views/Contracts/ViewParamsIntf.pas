unit ViewParamsIntf;

interface

uses
    BasicTypes;

type

    {------------------------------------------------
     interface for any class having capability as
     view parameters
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IViewParameters = interface
        ['{F93CA7D6-4454-4A04-A585-78BFF12F49E3}']
        function vars() : TArrayOfStrings;
        function getVar(const varName : string) : string;
        function setVar(const varName : string; const value :string) : IViewParameters;
    end;

implementation
end.
