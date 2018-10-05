unit JsonImpl;

interface

{$H+}

uses
    JsonIntf;
    s
type
    {------------------------------------------------
     interface for any class having capability to
     read data from json
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TJson = class(TInterfacedObject, IJson)
    private
        jsonContent : string;
    public
        constructor create(const jsonStr : string);
        destructor destroy(); override;
        function getIntValue(const keyName : string) : string;
    end;

implementation
    constructor TJson.create(const jsonStr : string);
    begin
        jsonContent := jsonStr;
    end;

    destructor TJson.destroy(); override;
    begin
        inherited destroy();
    end;

    function TJson.getIntValue(const keyName : string) : string;
    begin
        result := '';
    end;
end.
