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

procedure createThreads(aWorkerThreads:TArrThread;
   aepollFd, aListenFd, aExitFd, aTimerFd, atimeout: longint;
   aCleanIdleConnInterval,
   aMaxRequestSize,
   aMaxBodySize: integer);
const SUSPENDED = true;
var i: integer;
    accthrd: TIocpAcceptThread;
    thrd: TIocpWorkerThread;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    // create one dedicated thread for accept() and rest are conn worker threads
    accthrd := TIocpAcceptThread.create(
       SUSPENDED,
       aListenFd,
       aExitFd,
       aTimerFd,
       aClosePipeInFd,
       atimeout,
       aCleanIdleConnInterval,
       aMaxRequestSize,
       aMaxBodySize
    );
    {$IF DEFINED(FASTCGI)}
    accthrd.onAccepted := @FastCgiProcessor.OnAccepted;
    accthrd.OnBeforeClose := @FastCgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(SCGI)}
    accthrd.onAccepted := @ScgiProcessor.OnAccepted;
    accthrd.OnBeforeClose := @ScgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(UWSGI)}
    accthrd.onAccepted := @UwsgiProcessor.OnAccepted;
    accthrd.OnBeforeClose := @UwsgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(HTTP2)}
    accthrd.onAccepted := @Http2Processor.OnAccepted;
    accthrd.OnBeforeClose := @Http2Processor.OnBeforeClose;
    {$ELSE}
    accthrd.onAccepted := @HttpProcessor.OnAccepted;
    accthrd.OnBeforeClose := @HttpProcessor.OnBeforeClose;
    {$ENDIF}

    aWorkerThreads[0] := accthrd;

    for i:= 1 to poolSize - 1 do
    begin
        thrd := TIocpWorkerThread.create(
           SUSPENDED,
           aepollFd,
           aListenFd,
           aExitFd,
           aTimerFd,
           atimeout,
           aCleanIdleConnInterval,
           aMaxRequestSize,
           aMaxBodySize
        );

        {$IF DEFINED(FASTCGI)}
        thrd.OnDataAvail := @FastCgiProcessor.OnDataAvail;
        {$ELSEIF DEFINED(SCGI)}
        thrd.OnDataAvail := @ScgiProcessor.OnDataAvail;
        {$ELSEIF DEFINED(UWSGI)}
        thrd.OnDataAvail := @UwsgiProcessor.OnDataAvail;
        {$ELSEIF DEFINED(HTTP2)}
        thrd.OnDataAvail := @Http2Processor.OnDataAvail;
        {$ELSE}
        thrd.OnDataAvail := @HttpProcessor.OnDataAvail;
        {$ENDIF}

        aWorkerThreads[i] := thrd;
   end;
end;

function initListenFd(aport:word) : longint;
var
    addr: sockaddr_in;
    fd: TSocket;
    hints : addrinfo;
    addrlocal: paddrinfo;
    reuseAddr: longint;

    nRet, nZero: integer;
begin

    nRet := 0;
    nZero := 0;
    hints := default(addrinfo);
    addrlocal := nil;
    hints.ai_flags  = AI_PASSIVE;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_IP;

    if getaddrinfo(nil, aPort, @hints, addrlocal) <> 0  then
    begin
        // log error WSAGetLastError()
        exit(-1);
    end

    if addrlocal = nil then
    begin
        // log error WSAGetLastError()
        exit(-2);
    end;

   fd := WSASocket(addrlocal^.ai_family,
       addrlocal^.ai_socktype,
       addrlocal^.ai_protocol,
       nil,
       0,
       WSA_FLAG_OVERLAPPED);

   if fd = INVALID_SOCKET then
   begin
       // log error WSAGetLastError()
       exit(-3);
   end;

   nRet := bind(fd, addrlocal^.ai_addr, integer(addrlocal^.ai_addrlen));
   if nRet = SOCKET_ERROR then
   begin
       // log error WSAGetLastError()
       exit(-4);
   end;

   nRet := listen(fd, 5);
   if nRet = SOCKET_ERROR  then
   begin
       // log error WSAGetLastError()
       exit(-5);
   end

   result := 0;
end;


// The handler function must use stdcall or winapi
function ExitConsoleHandler(dwCtrlType: DWORD): BOOL; stdcall;
begin

    // Return True to indicate the signal was handled.
    Result := True;
end;

function fanoRun(): longint;
var
    hIOCP: HANDLE;
    aListenFd: Socket;
    aExitFd: longint;
    err: longint;
begin
    result := 0;
    if not SetConsoleCtrlHandler(@ExitConsoleHandler, true) then
    begin
       exit(-1);
    end;

    // Initialize Winsock
    err:= WSAStartup(MAKEWORD(2, 2), wsaData);
    if err <> 0 then
    begin
        SetConsoleCtrlHandler(@ExitConsoleHandler, false);
        exit(err);
    end

    hIOCP := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);

    if aEventFd = 0 then
    begin
       // todo: error handling
       exit;
    end;

    aListenFd := initListenFd(hIOCP, mainCfg.Port);
    if aListenFd < 0 then
    begin
       // todo: error handling
       exit;
    end;


    createThreads(workerThreads,
        aEventFd,
        aListenFd,
        aExitFd,
        aTimerFd,
        mainCfg.Timeout,
        mainCfg.);

    runThreads(workerThreads);
    waitThreads(workerThreads);
    freeThreads(workerThreads);


    if hIOCP <> 0 then
    begin
    	CloseHandle(hIOCP);
    	hIOCP = 0;
    end;

   if aListenFd <> INVALID_SOCKET then
   begin
       CloseSocket(aListenFd);
       aListenFd := INVALID_SOCKET;
   end;

   WSACleanup();
   SetConsoleCtrlHandler(@ExitConsoleHandler, false);
end;
