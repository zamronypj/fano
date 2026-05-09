{-------------------------------------------------------------------------------
MIT License

Copyright (c) 2018 - Present Zamrony P. Juhara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------}
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
       // max data in bytes we want to read from client
       maxRequestSize: longint;

       // data need write to client connection
       outputData: TMemoryStream;

       // total data sent to client
       totalSent: longint;

       // contain parsed HTTP request
       httpData: THttpData;
    end;
    PBuff = ^TBuff;

    procedure OnAccepted(const connfd: longint;
        maxRequestSize, maxBodySize: integer;
        var userData: pointer);

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

uses
    sockets,
    {$IFDEF WINDOWS}
    Windows,
    Winsock,
    Winsock2,
    {$ELSE}
    baseunix,
    unix,
    {$ENDIF}
    HttpHeaders;

procedure OnAccepted(const connfd: longint;
        maxRequestSize, maxBodySize: integer;
        var userData: pointer);
var buf: PBuff;
begin
   new(buf);
   buf^.inputData := TMemoryStream.Create();
   buf^.outputData := TMemoryStream.Create();
   buf^.totalSent := 0;
   buf^.maxRequestSize := maxRequestSize;
   buf^.httpData:= default(THttpData);
   buf^.httpData.state := hpsWaitingHeader;
   buf^.httpData.headers := THttpHeaders.Create();
   buf^.httpData.maxBodySize := maxBodySize;
   userData := buf;
end;

{$IFDEF WINDOWS}
procedure handleRead(fd: TSocket; userData: pointer; var isRead, isEnded, isError: boolean);
var
    n: longint;
    buf: PBuff;
    tmp : string;
    oldState: THttpProcessingState;
    aWSABuf: WSABUF;
    bytesRecv, aflags: Dword;
    ovrlapped: TOverlapped;
begin
    buf := PBuff(userData);
    setlength(tmp, 1024);
    while true do
    begin
        if WSARecv(fd, @aWSABuf, 1, BytesRecv, aFlags, @Ovrlapped, nil) = SOCKET_ERROR then
        begin
           if WSAGetLastError <> WSA_IO_PENDING then
           begin
               dispose(ovrlapped);
               closeConnData(conn);;
           end;
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

{$ELSE}
procedure handleRead(fd: longint; userData: pointer; var isRead, isEnded, isError: boolean);
var
    n: longint;
    buf: PBuff;
    tmp : string;
    oldState: THttpProcessingState;
begin
    buf := PBuff(userData);
    if buf = nil then
    begin
       isError := true;
       exit;
    end;

    setlength(tmp, 1024);
    while true do
    begin
        n := fpRecv(fd, @tmp[1], 1024, 0);
        if n > 0 then
        begin
            if buf^.inputData.Size + n > buf^.maxRequestSize then
            begin
               // request bytes exceed max request size so reject it
               isError := true;
               isRead := false;
               exit;
            end;

            buf^.inputData.write(tmp[1], n);
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
{$ENDIF}

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

    abuf := PBuff(userData);

    HttpParser.parseHttp(abuf^.inputData, abuf^.httpData);

    if (abuf^.totalSent = 0) and (abuf^.outputData.size = 0) then
    begin
        if (abuf^.httpData.state = hpsBadRequest) then
        begin
            astr:= 'HTTP/1.1 400 Bad Request';
        end else
        begin
            astr:= 'HTTP/1.1 200 OK' + #13#10 +
               'Content-type: text/html' + #13#10#13#10 +
               '<html><head><title>Hello fano</title></head><body><h1>'+abuf^.httpData.requestPath+'</h1></body></html>';
        end;
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
