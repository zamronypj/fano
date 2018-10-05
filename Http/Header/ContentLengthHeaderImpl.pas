unit ContentLengthHeaderImpl;

interface
{$H+}

uses
  HeaderIntf,
  SetHeaderIntf,
  HeaderSetterWriterImpl;

type

    TContentLengthHeader = class(THeaderSetterWriter)
    protected
        function headerName() : string; override;
    end;

implementation

    function TContentLengthHeader.headerName() : string;
    begin
       result := 'Content-Length';
    end;

end.
