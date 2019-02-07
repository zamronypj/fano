unit Redis.TCPClient;

interface

uses
  SysUtils, Redis;

function getTCPClient : ITCPClient;

implementation

uses
  IdTCPClient, IdGlobal;

type
  TRedisTCPClient = class (TInterfacedObject, ITCPClient) // Adapter [ITCPClient <-> TIdTCPClient]
  private
    fClient : TIdTCPClient;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Connect(aHost : string; aPort : integer);
    procedure Disconnect;
    procedure Write(aText : TBytes);
    procedure WriteLn(aText : string);
    function ReadLn : string;
    function IsConnected : boolean;
    function ReadBytes(count : integer) : TBytes;
  end;

function getTCPClient : ITCPClient;
begin
  result := TRedisTCPClient.Create;
end;

{ TRedisTCPClient }

procedure TRedisTCPClient.Connect(aHost: string; aPort: integer);
begin
  fClient.Connect(aHost, aPort);
end;

constructor TRedisTCPClient.Create;
begin
  fClient := TIdTCPClient.Create;
end;

destructor TRedisTCPClient.Destroy;
begin
  fClient.Free;
  inherited;
end;

procedure TRedisTCPClient.Disconnect;
begin
  fClient.Disconnect;
end;

function TRedisTCPClient.IsConnected: boolean;
begin
  result := fClient.Connected;
end;

function TRedisTCPClient.ReadBytes(count: integer): TBytes;
begin
  fClient.IOHandler.ReadBytes( result, count);
end;

function TRedisTCPClient.ReadLn: string;
begin
  result := fClient.IOHandler.ReadLn;
end;

procedure TRedisTCPClient.Write(aText: TBytes);
begin
  fClient.IOHandler.Write(aText);
end;

procedure TRedisTCPClient.WriteLn(aText: string);
begin
  fClient.IOHandler.WriteLn(aText);
end;

end.
