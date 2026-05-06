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
        procedure runLoop(); override;
   end;

implementation

uses
   DateUtils,
   NetUtil,
   TimerEpollEvUtil,
   Logger;

function TIocpAcceptThread.handleAcceptConn(connfd: TSocket): TOpStatus;
var clnt_addr: sockaddr_in;
    clnt_addr_len : socklen_t;
    connfd, err: longint;
    connEv: epoll_event;
    conn: PConnData;
begin
    result := default(TOpStatus);
    while true do
    begin
        clnt_addr := default(sockaddr_in);
        clnt_addr_len := sizeof(clnt_addr);

        // if we get here we can assume ev.data.fd = fListenFD
        connfd := WSAAccept(ev.data.fd, @clnt_addr, @clnt_addr_len);

        if (connfd < 0) then
        begin
            err := SocketError;
            if (err = EsysEAGAIN) or (err = EsysEWOULDBLOCK) then
            begin
                result.wouldBlocked := true;
            end else
            begin
                result.error := true;
                result.errCode := err;
                result.errMsg := 'accept() failed. Fd: ' +
                    intToStr(connfd) + ' Err: ' +
                    intToStr(err) ;
            end;
            exit;
        end;

        conn := addFdToConnData(connfd);
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

        // trigger event OnAccepted to allow caller to do something with
        // epoll event such as associate event with user-defined data
        fireAcceptEv(conn);

        if CreateIoCompletionPort(clientSocket, fEventFd, ULONG_PTR(Conn), 0) = 0 then
        begin
            result.error := true;
            result.errCode := err;
            result.errMsg := 'accept() failed. Add IOCP Fd: ' +
                intToStr(connfd) + ' Err: ' +
                intToStr(err) ;

        end;

    end;
end;

procedure TIocpAcceptThread.RunLoop();
const WAIT_FOREVER_UNTIL_EV = -1;
var status: TOpStatus;
    eventHandle: HANDLE;
    waitResult : Dword;
    clientSocket: TSocket;
    conn : PConnData;
begin
    // 2. Create an event object
    eventHandle := WSACreateEvent();

    // 3. Associate socket with event object for FD_ACCEPT and FD_CLOSE
    WSAEventSelect(fListenFd, eventHandle, FD_ACCEPT or FD_CLOSE);

    while (true) do
    begin
        // 4. Wait for the event
        waitResult := WSAWaitForMultipleEvents(1, @eventHandle, false, INFINITE, false);
        if (waitResult = WSA_WAIT_EVENT_0) then
        begin
            // 5. Enumerate events to find out what happened
            WSAEnumNetworkEvents(listenSocket, eventHandle, @networkEvents);

            if (networkEvents.lNetworkEvents and FD_ACCEPT) = FD_ACCEPT then
            begin
                if (networkEvents.iErrorCode[FD_ACCEPT_BIT] = 0) then
                begin
                    clientSocket = WSAAccept(listenSocket, nil, nil);
                    handleAcceptConn(clientSocket);
                end;
            end;

            if (networkEvents.lNetworkEvents and FD_CLOSE) = FD_CLOSE then
            begin
                // printf("Socket closed.\n");
                break;
            end;
       end;
    end;
end;

end.
