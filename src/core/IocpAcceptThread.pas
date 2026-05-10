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
unit IocpAcceptThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   windows,
   winsock2,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type


   { TIocpAcceptThread }

   TIocpAcceptThread = class(TDaemonWorkerThread)
   private
        function handleAcceptConn(): TOpStatus;
   protected
        procedure RunLoop(); override;
   public
        constructor Create(
                    aSuspended : boolean;
                    aListenFd: longint;
                    aExitFd: longint;
                    aTimerFd: longint;
                    aClosePipeInFd: longint;
                    aTimeout: longint;
                    aCleanIdleConnInterval,
                    aMaxRequestSize,
                    aMaxBodySize,
                    aThreadPoolSize: integer);
   end;

implementation

uses
   DateUtils,
   NetUtil,
   Logger;

procedure acceptCallback(connfd: TSocket; var userData: pointer; callbackData: pointer);
var worker: TIocpAcceptThread;
begin
    worker := TIocpAcceptThread(callbackData);
    worker.OnAccepted(connfd, worker.maxRequestSize, worker.MaxBodySize, userData);
end;

procedure removeCallback(connfd: TSocket; var userData: pointer; callbackData: pointer);
begin
    TIocpAcceptThread(callbackData).OnBeforeClose(connfd, userData);
end;

function TIocpAcceptThread.handleAcceptConn(alistenFd: THandle): TOpStatus;
var clnt_addr: sockaddr_in;
    clnt_addr_len : socklen_t;
    err: longint;
    connfd: TSocket;
begin
    result := default(TOpStatus);

    clnt_addr := default(sockaddr_in);
    clnt_addr_len := sizeof(clnt_addr);

    // if we get here we can assume ev. = hIOCP
    connfd := WSAAccept(aListenFd, @clnt_addr, @clnt_addr_len, nil, nil);

    if (connfd = INVALID_SOCKET) then
    begin
        err := WSAGetLastError();
        if err = WSAEWOULDBLOCK then
        begin
            continue;
        end;

        result.error := true;
        result.errCode := err;
        result.errMsg := 'WSAAccept() failed. Err: ' + intToStr(err) ;
        exit;
    end;

    conn := addFdToConnData(connfd, self, @acceptCallback);
    if conn = nil then
    begin
        // can not handle more connection, reject it and move on
        fpClose(connfd);
        result.error := true;
        result.errCode := ESysENOMEM;
        result.errMsg := 'accept() failed. Fd: ' +
            intToStr(connfd) + ' Err: MAXCONN';
        exit;
    end;

    setNonBlocking(connfd);

    // post initial receive on this socket
    nRet := WSARecv(connfd, @conn^.wsabuf, 1, @dwRecvNumBytes, @dwFlags, @conn^.overlapData, nil);
    if  (nRet = SOCKET_ERROR) and (WSAGetLastError() <> ERROR_IO_PENDING) then
    begin
        removeFromConnData(conn, self, @removeCallback);
    	CloseSocket(connfd);
    end;
end;

procedure TIocpAcceptThread.RunLoop();
var
    i: integer;
    conn : PConnData;
begin
    while (true) do
    begin
        handleAcceptConn(fListenFd);
    end;

    // send SHUTDOWN_KEY to wake up and stop all IocpWorkerThread
    // start from 1 as ourself also counted as thread pool
    for i:= 1 to fThreadPoolSize-1 do
    begin
        iocpterm.term(hIOCP);
    end;
end;

end.
