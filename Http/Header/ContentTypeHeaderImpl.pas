unit ContentTypeHeaderImpl;


interface
{$H+}

uses
    HeaderIntf,
    SetHeaderIntf;

type

    TContentTypeHeader = class(THeaderSetterWriter)
    protected
        function headerName() : string; override;
    end;

implementation

    function TContentTypeHeader.headerName() : string;
    begin
       result := 'Content-Type';
    end;

end.
