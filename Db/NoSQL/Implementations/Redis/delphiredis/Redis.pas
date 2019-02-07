unit Redis;

interface

uses

    SysUtils;

type
    ITCPClient = interface
        ['{89222181-1BA4-4FDD-B100-30FFBE4FC661}']
        procedure Connect(aHost: string; aPort: integer);
        procedure Disconnect;
        procedure Write(aText: TBytes);
        procedure WriteLn(aText: string);
        function ReadLn: string;
        function ReadBytes(count : integer) : TBytes;
        function IsConnected : boolean;
    end;

    IRedisConnection = interface
        ['{83044628-09DE-43AE-ACB8-B3C04B07A573}']
        function getHost: string;
        procedure setHost(const Value: string);
        property Host: string read getHost write setHost;

        function getPort: integer;
        procedure setPort(const Value: integer);
        property Port: integer read getPort write setPort;

        function getClient: ITCPClient;
        procedure setClient(const Value: ITCPClient);
        property TCPClient: ITCPClient read getClient write setClient;

        function Auth(aPassword: AnsiString): string;
        function ExecuteQuery( const aCommand : AnsiString): TArray<TBytes>;  overload;
        function ExecuteQuery( const aQuery: TArray<TBytes>): TArray<TBytes>;  overload;
    end;

    TRedis = class
    public
      class function getConnection(aHost: string = 'localhost';
                                   aPort: integer = 6379;
                                   aTCPClient: ITCPClient = nil) : IRedisConnection;
    end;

    RedisException = class(Exception);

implementation

uses

    Redis.Connection;

    { TRedis }

    class function TRedis.getConnection(
        const aHost: string;
        const aPort: integer;
        const aTCPClient: ITCPClient
    ) : IRedisConnection;
    begin
        result := getRedisConnection(aTCPClient);
        result.Host := aHost;
        result.Port := aPort;
    end;

end.
