unit HeaderSetterWriterImpl;

interface

uses HeaderIntf, SetHeaderIntf;

type

    THeaderSetterWriter = class(TInterfacedObject, IHeaderInterface, ISetHeaderInterface)
    private
        headerValue : string;
    protected
        function headerName() : string; virtual; abstract;
    public
        function setValue(const headerValue : string) : ISetHeaderInterface;
        function writeHeader() : IHeaderInterface;
    end;

implementation

    function THeaderSetterWriter.setValue(const headerValue :string) : ISetHeaderInterface;
    begin
        self.headerValue := headerValue;
        result := self;
    end;

    function THeaderSetterWriter.writeHeader() : IHeaderInterface;
    begin
       writeln(self.headerName() + ': ' + self.headerValue);
       result := self;
    end;

end.
