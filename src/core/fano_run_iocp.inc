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

function initListenFd(eventfd: THandle; aport:word) : longint;
var
    addr: sockaddr_in;
    fd: longint;
    listenEv : epoll_event;
    reuseAddr: longint;
begin
   fd := fpsocket(AF_INET, SOCK_STREAM, 0);
   result := fd;

   if fd < 0 then
   begin
      // todo: error handling
      exit(ERR_SOCK);
   end;

   setNonBlocking(fd);

   addr := default(sockaddr_in);
   addr.sin_family := AF_INET;
   addr.sin_port := htons(aport);
   addr.sin_addr.s_addr := INADDR_ANY;

   // reuse address so that when daemon restart will use same address:port
   reuseAddr := 1;
   fpSetSockOpt(fd, SOL_SOCKET, SO_REUSEADDR, @reuseAddr, sizeof(reuseAddr));

   if fpbind(fd, @addr, sizeof(addr)) < 0 then
   begin
      // todo: error handling
      exit(ERR_BIND);
   end;

   if fplisten(fd, SOMAXCONN) < 0 then
   begin
      // todo: error handling
      exit(ERR_LISTEN);
   end;

   result := CreateIoCompletionPort(aEventFd, 0, 0, 0);
end;


function fanoRun(): longint;
var
    aEventFd: HANDLE;
    aListenFd: longint;
    aTimerFd: longint;
    aExitFd: longint;
begin
    result := 0;

    aEventFd := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);

    if aEventFd = 0 then
    begin
       // todo: error handling
       exit;
    end;

    aListenFd := initListenFd(aEventFd, mainCfg.Port);
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

    epoll_ctl(aEventFd, EPOLL_CTL_DEL, aListenFd, nil);
    epoll_ctl(aEventFd, EPOLL_CTL_DEL, aExitFd, nil);

    // no need to close fExitFd as this will be done automatically
    // in SigTermUtil unit finalization
    fpClose(aTimerFd);
    fpClose(aListenFd);
    fpClose(aEventFd);
end;
