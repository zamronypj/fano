unit ContentLengthHeaderImpl;

uses HeaderIntf, SetHeaderIntf, HeaderSetterWriterImpl;

interface

{$MODE OBJFPC}
{$INTERFACES CORBA}
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
