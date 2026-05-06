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
   aCleanIdleConnInterval: integer);
const SUSPENDED = true;
var i: integer;
    thrd: TIocpWorkerThread;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    for i:= 0 to poolSize - 1 do
    begin
        thrd := TIocpWorkerThread.create(
           SUSPENDED,
           aepollFd,
           aListenFd,
           aExitFd,
           aTimerFd,
           atimeout,
           aCleanIdleConnInterval
        );

        {$IF DEFINED(FASTCGI)}
        thrd.onAccepted := @FastCgiProcessor.OnAccepted;
        thrd.OnDataAvail := @FastCgiProcessor.OnDataAvail;
        thrd.OnBeforeClose := @FastCgiProcessor.OnBeforeClose;
        {$ELSEIF DEFINED(SCGI)}
        thrd.onAccepted := @ScgiProcessor.OnAccepted;
        thrd.OnDataAvail := @ScgiProcessor.OnDataAvail;
        thrd.OnBeforeClose := @ScgiProcessor.OnBeforeClose;
        {$ELSEIF DEFINED(UWSGI)}
        thrd.onAccepted := @UwsgiProcessor.OnAccepted;
        thrd.OnDataAvail := @UwsgiProcessor.OnDataAvail;
        thrd.OnBeforeClose := @UwsgiProcessor.OnBeforeClose;
        {$ELSEIF DEFINED(HTTP2)}
        thrd.onAccepted := @Http2Processor.OnAccepted;
        thrd.OnDataAvail := @Http2Processor.OnDataAvail;
        thrd.OnBeforeClose := @Http2Processor.OnBeforeClose;
        {$ELSE}
        thrd.onAccepted := @HttpProcessor.OnAccepted;
        thrd.OnDataAvail := @HttpProcessor.OnDataAvail;
        thrd.OnBeforeClose := @HttpProcessor.OnBeforeClose;
        {$ENDIF}

        aWorkerThreads[i] := thrd;
   end;
end;

function initListenFd(epoll_fd: longint; aport:word) : longint;
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

   listenEv := default(epoll_event);
   // need to use edge-triggered so that only one thread get notified
   // when listen socket has something to read
   listenEv.events := EPOLLIN OR EPOLLET;
   listenEv.data.fd := fd;
   if epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, @listenEv) < 0 then
   begin
      exit(ERR_EV_ADD);
   end;

end;

function initExitFd(epoll_fd : longint) : longint;
var fd: longint;
    exitEv : epoll_event;
begin
    fd := getExitFd();
    result := fd;

    if fd < 0 then
    begin
        // todo: error handling
        writeln('exit fd failed');
        exit;
    end;

    // need to use level-triggered so that all threads get notified
    // when program termination is called
    exitEv := default(epoll_event);
    exitEv.events := EPOLLIN;
    exitEv.data.fd := fd;
    epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, @exitEv);
end;


function initTimerFd(epoll_fd:longint; ainterval: integer): longint;
var
  ret, fd : longint;
  timeout : itimerspec;
begin
    fd := timerfd_create(CLOCK_MONOTONIC, 0);
    result := fd;
    if fd < 0 then
    begin
        // todo: error handling
        exit(fd);
    end;
    SetNonBlocking(fd);

    // Set the timer to expire initially in ainterval second,
    // and then every ainterval second
    timeout.it_value.tv_sec := ainterval;
    timeout.it_value.tv_nsec := 0;
    timeout.it_interval.tv_sec := ainterval;
    timeout.it_interval.tv_nsec := 0;
    ret := timerfd_settime(fd, 0, @timeout, nil);
    if ret < 0 then
    begin
        exit(ret);
    end;

    addTimerEv(epoll_fd, fd);
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

    aTimerFd := initTimerFd(aEventFd, mainCfg.CleanIdleConnInterval);
    if aTimerFd < 0 then
    begin
       // todo: error handling
       writeln('error set timer Err: ', errno);
       exit;
    end;

    aExitFd := initExitFd(aEventFd);
    if aExitFd < 0 then
    begin
       // todo: error handling
       exit;
    end;

    createThreads(workerThreads,
        aEventFd,
        aListenFd,
        aExitFd,
        aTimerFd,
        mainCfg.Timeout);

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
