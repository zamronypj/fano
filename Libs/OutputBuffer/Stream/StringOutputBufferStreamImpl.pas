unit StringOutputBufferStreamImpl;

interface

{$H+}

uses
    classes,
    OutputBufferStreamIntf,
    OutputBufferStreamImpl;

type

    TStringOutputBufferStream = class (TOutputBufferStreamAdapter, IOutputBufferStream)
    protected
        function createStream() : TStream; override;
    public
        function getContent() : string; override;
    end;

implementation

    function TStringOutputBufferStream.createStream() : TStream;
    begin
        result := TStringStream.create('');
    end;

    function TStringOutputBufferStream.getContent() : string;
    begin
        //fstream always TStringStream, so this is safe typecast
        result := TStringStream(fstream).dataString;
    end;

end.