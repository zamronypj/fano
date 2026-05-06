unit HttpProcessor;

{$MODE OBJFPC}
{$H+}

interface

uses
    Classes,
    SysUtils,
    httpprotocol,
    HttpParser;

type

    TBuff = record
       // data read from client connection
       inputData: TMemoryStream;
       // total data read from client
       totalRead: longint;

       // data need write to client connection
       outputData: TMemoryStream;

       // total data sent to client
       totalSent: longint;

       // contain parsed HTTP request
       httpData: THttpData;
    end;
    PBuff = ^TBuff;

    procedure OnAccepted(const connfd: longint; var userData: pointer);

    procedure OnDataAvail(
            const connfd: longint;
            var userData: pointer;
            var isRead: boolean;
            var isWrite : boolean;
            var isEnded :boolean;
            var isError: boolean);

    procedure OnBeforeClose(const connfd: longint;
            var userData: pointer;
            var canClose: boolean);

implementation

uses sockets, baseunix, unix, contnrs;

procedure OnAccepted(const connfd: longint; var userData: pointer);
var buf: PBuff;
begin
   new(buf);
   buf^.inputData := TMemoryStream.Create();
   buf^.outputData := TMemoryStream.Create();
   buf^.totalSent := 0;
   buf^.totalRead := 0;
   buf^.httpData:= default(THttpData);
   buf^.httpData.state := hpsStart;
   buf^.httpData.headers := TFPHashList.Create();
   userData := buf;
end;


procedure handleRead(fd: longint; userData: pointer; var isRead, isEnded, isError: boolean);
var
    n: longint;
    buf: PBuff;
    tmp : string;
    oldState: THttpProcessingState;
begin
    buf := PBuff(userData);
    setlength(tmp, 1024);
    while true do
    begin
        n := fpRecv(fd, @tmp[1], 1024, 0);
        if n > 0 then
        begin
            oldState := buf^.httpData.state;
            HttpParser.parseHttp(tmp, n, buf^.httpData);
            if oldState = buf^.httpData.state then
            begin
                // we havent found what we are looking so keep reading at prev pos
            end;
        end else
        if (n = 0) then
        begin
            isEnded := true;
            isRead := false;
            exit;
        end else
        begin
            if (errno = ESysEAGAIN) or (errno = ESysEWOULDBLOCK) then
            begin
                // Buffer empty, wait for next epoll notification,
                // Modify epoll interest list to include EPOLLIN
                isRead := true;
                exit;
            end;

            isError := true;
            isRead := false;
            exit;
        end;
    end;
end;

procedure handleWrite(fd: longint; userData: pointer; var isWrite, isEnded, isError: boolean);
const MAX_BYTE_TO_SEND = 4 * 1024;
var n, bytesToWrite : longint;
    buf: PBuff;
begin
    buf := PBuff(userData);
    while (buf^.totalSent < buf^.outputData.size) do
    begin

        bytesToWrite := buf^.outputData.size - buf^.totalSent;
        if bytesToWrite > MAX_BYTE_TO_SEND then
        begin
            bytesToWrite := MAX_BYTE_TO_SEND;
        end;

        n := fpSend(fd, PByte(buf^.outputData.Memory + buf^.totalSent), bytesToWrite, 0);

        if (n >= 0) then
        begin
            inc(buf^.totalSent, n);
        end else
        begin
            if (errno = EsysEAGAIN) or (errno = ESysEWOULDBLOCK) then
            begin
                // Kernel buffer full
                // 1. Save remaining data in an application-level buffer
                // 2. Modify epoll interest list to include EPOLLOUT
                isWrite := true;
                exit;
            end;
            isError := true;
            isWrite := false;
            exit;
        end;
    end;
    // Finished sending; modify epoll to remove EPOLLOUT interest
    isWrite := false;
    isEnded := true;
end;

procedure OnDataAvail(
    const connfd: longint;
    var userData: pointer;
    var isRead: boolean;
    var isWrite : boolean;
    var isEnded : boolean;
    var isError: boolean);
var abuf: PBuff;
    astr: string;
begin
    if isRead then
    begin
        handleRead(connfd, userData, isRead, isEnded, isError);
    end;

    if isError then
    begin
       exit;
    end;

    // TODO: read and parse HTTP request
    // for now we just echo back
    abuf := PBuff(userData);

    if (abuf^.totalSent = 0) and (abuf^.outputData.size = 0) then
    begin
        astr:= 'HTTP/1.1 200 OK' + #13#10 +
           'Content-type: text/html' + #13#10#13#10 +
           '<html><head><title>Hello fano</title></head><body><h1>Hello</h1></body></html>';
        abuf^.outputData.Write(astr[1], length(astr));
    end;

    handleWrite(connfd, userData, isWrite, isEnded, isError);
end;

procedure OnBeforeClose(
    const connfd: longint;
    var userData: pointer;
    var canClose: boolean);
var buf: PBuff;
begin
    if userData = nil then
    begin
        exit;
    end;

    buf := PBuff(userData);
    buf^.inputData.Free();
    buf^.outputData.Free();
    buf^.httpData.headers.Free();
    dispose(buf);
    userData := nil;
end;

end.
