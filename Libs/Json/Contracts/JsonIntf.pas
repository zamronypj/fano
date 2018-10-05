unit JsonIntf;

interface

{$H+}

type
    {------------------------------------------------
     interface for any class having capability to
     read data from json
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IJson = interface
        ['{7D4419F2-99B5-4C56-A6FB-2C44E86BEC8F}']
        function getIntValue(const keyName : string) : string;
    end;

implementation
end.
