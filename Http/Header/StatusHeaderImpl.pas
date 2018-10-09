unit StatusHeaderImpl;


interface
{$H+}

uses
    HeaderIntf,
    SetHeaderIntf;

type

    TStatusHeader = class(THeaderSetterWriter)
    protected
        function headerName() : string; override;
    end;

implementation

    function TStatus.headerName() : string;
    begin
       result := 'Status';
    end;

end.
