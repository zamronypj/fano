unit ContentTypeHeaderImpl;

uses HeaderIntf, SetHeaderIntf;

interface

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
