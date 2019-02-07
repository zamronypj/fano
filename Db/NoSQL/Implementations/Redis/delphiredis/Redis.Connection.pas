unit Redis.Connection;

interface

uses
  Classes, Redis;

  function getRedisConnection(aClient : ITCPClient = nil) : IRedisConnection;

implementation

uses
  SysUtils, Redis.TCPClient;

const
  CrLf = #13#10;

type
  TRedisConnection = class (TInterfacedObject, IRedisConnection)
  private
    fHost : string;
    fPassword : string;
    fPort : integer;
    fUsername : string;
    fClient : ITCPClient;
    function getHost: string;
    function getPassword: string;
    function getPort: integer;
    function getUser: string;
    procedure setHost(const Value: string);
    procedure setPassword(const Value: string);
    procedure setPort(const Value: integer);
    procedure setUser(const Value: string);
    function tokenize(input : AnsiString) : TArray<AnsiString>;
    function getClient: ITCPClient;
    procedure setClient(const Value: ITCPClient);
  public
    property Host : string read getHost write setHost;
    property Port : integer read getPort write setPort;
    property Username : string read getUser write setUser;
    property Password : string read getPassword write setPassword;
    property TCPClient : ITCPClient read getClient write setClient;
    function ExecuteQuery( const aCommand : AnsiString): TArray<TBytes>;  overload;
    function ExecuteQuery( const aQuery: TArray<TBytes>): TArray<TBytes>;  overload;
    function Auth(aPassword: AnsiString): string;
  end;

function getRedisConnection(aClient : ITCPClient = nil) : IRedisConnection;
begin
  result := TRedisConnection.Create;
  result.Host := 'localhost';
  result.Port := 6379;
  if aClient = nil then aClient := getTCPClient;
  result.TCPClient := aClient;
end;

{ TRedisConnection }

function TRedisConnection.Auth(aPassword: AnsiString): string;
var args, retval : TArray<TBytes>;
begin
  SetLength( args, 2);
  args[0] := BytesOf('AUTH');
  args[1] := BytesOf(aPassword);

  retval := ExecuteQuery( args);
  if Length(retval) <> 1
  then raise RedisException.Create('Unexpected reply');

  result := string( PAnsiChar(retval[0]));
end;

function TRedisConnection.ExecuteQuery( const aCommand : AnsiString): TArray<TBytes>;  
var tokens : TArray<AnsiString>;
    args   : TArray<TBytes>;
    i      : Integer;
begin
  tokens := tokenize( aCommand);

  SetLength( args, Length(tokens));
  for i := Low(tokens) to High(tokens)
  do args[i] := BytesOf( tokens[i]);

  result := ExecuteQuery( args);
end;

function TRedisConnection.ExecuteQuery(const aQuery: TArray<TBytes>): TArray<TBytes>;
var
  command : TMemoryStream;
  i, count, bytes : integer;
  s : string;
  sAnsi : AnsiString;
  cmdbuf : TBytes;
begin
  command := TMemoryStream.Create;
  try
    sAnsi := '*' + AnsiString(IntToStr(Length(aQuery)) + CrLf);
    command.WriteBuffer( sAnsi[1], Length(sAnsi));
    for i := Low(aQuery) to High(aQuery) do
    begin
      sAnsi := '$' + AnsiString(IntToStr(Length(aQuery[i])) + CrLf);
      command.WriteBuffer( sAnsi[1], Length(sAnsi));
      command.WriteBuffer( aQuery[i][0], Length(aQuery[i]));
      sAnsi := AnsiString(CrLf);
      command.WriteBuffer( sAnsi[1], Length(sAnsi));
    end;

    // TODO: To be improved. Actually this is less optimal for large queries,because we effectively 
    // need twice the memory here. But TMemoryStream is much easier to deal with than TBytes ...
    SetLength( cmdbuf, command.Size);
    Move( command.Memory^, cmdbuf[0], Length(cmdbuf));

    if not fClient.IsConnected then fClient.Connect(fHost, fPort);
    fClient.Write( cmdbuf);
  finally
    FreeAndNil(command);
  end;

  repeat
    s := fClient.ReadLn;
  until s <> ''; // happens under high load, not quite clear what causes this
  case s[1] of
    '-' : raise RedisException.Create(s);

    '+',          // string reply
    ':' : begin   // integer reply
      delete(s,1,1);
      SetLength(result,1);
      result[0] := BytesOf( AnsiString(s));
    end;

    '$' : begin
      delete(s,1,1);
      bytes := StrToInt(s);
      // The client library API should not return an empty string, but a nil object,
      // when the requested object does not exist. For example a Ruby library should
      // return 'nil' while a C library should return NULL (or set a special flag in
      // the reply object), and so forth.
      if bytes <= 0   // FIX: App hangs on "null bulk reply" = '$-1';
      then raise RedisException.Create('No data');
      SetLength(result,1);
      result[0] := fClient.ReadBytes(bytes);
      fClient.ReadBytes(2); // Discard CrLf
    end;

    '*' : begin
      delete(s,1,1);
      count := StrToInt(s);

      // A client library API should return a null object and not an empty Array
      // when Redis replies with a Null Multi Bulk Reply. This is necessary to distinguish
      // between an empty list and a different condition (for instance the timeout condition
      // of the BLPOP command).
      if count < 0 then begin
        raise RedisException.Create('No data');
        Exit;
      end;

      SetLength(result,count);
      for i := 1 to count do
      begin
        s := fClient.ReadLn;
        delete(s,1,1);
        bytes := StrToInt(s);
        if bytes > 0 then begin  // FIX: can't read negative byte count
          result[i] := fClient.ReadBytes(bytes);
          fClient.ReadBytes(2); // Discard CrLf
        end;
      end;
    end;

  else
    raise RedisException.Create('Unexpected reply "'+s+'"');
  end;
end;

function TRedisConnection.getClient: ITCPClient;
begin
  result := fClient;
end;

function TRedisConnection.getHost: string;
begin
  result := fHost;
end;

function TRedisConnection.getPassword: string;
begin
  result := fPassword;
end;

function TRedisConnection.getPort: integer;
begin
  result := fPort;
end;

function TRedisConnection.getUser: string;
begin
  result := fUsername;
end;

procedure TRedisConnection.setClient(const Value: ITCPClient);
begin
  fClient := Value;
end;

procedure TRedisConnection.setHost(const Value: string);
begin
  fHost := Value;
end;

procedure TRedisConnection.setPassword(const Value: string);
begin
  fPassword := Value;
end;

procedure TRedisConnection.setPort(const Value: integer);
begin
  fPort := Value;
end;

procedure TRedisConnection.setUser(const Value: string);
begin
  fUsername := Value;
end;

function TRedisConnection.tokenize(input: AnsiString): TArray<AnsiString>;
const
  whitespace = [' ', #08, #09, #10, #12, #13];
var
  s : AnsiString;

  procedure append(value : AnsiString);
  begin
    if value <> '' then
    begin
      setlength(result, length(result)+1);
      result[high(result)] := value;
    end;
  end;

begin
  s := '';
  while length(input) > 0 do
  begin
    if CharInSet(input[1], whitespace) then
    begin
      append(s);
      s := '';
    end
    else
    begin
      s := s + input[1];
    end;
    delete(input,1,1);
  end;
  append(s);
  s := '';
end;

end.
