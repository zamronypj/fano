unit ContentLengthHeaderImpl;

uses HeaderIntf, SetHeaderIntf, HeaderSetterWriterImpl;

interface

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
