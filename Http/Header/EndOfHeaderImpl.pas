unit EndOfHeaderImpl;

interface
{$H+}

uses
    HeaderIntf;

type

    TEndOfHeader = class(TInterfacedObject, IHeaderInterface)
        function writeHeader() : IHeaderInterface;
    end;

implementation

function TEndOfHeader.writeHeader() : IHeaderInterface;
begin
   writeln();
   result := self;
end;

end.
