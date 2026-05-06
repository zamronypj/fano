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
   aKqFd, aListenFd, aExitFd, aTimerFd, atimeout: longint;
   aCleanIdleConnInterval: integer);
const SUSPENDED = true;
var i: integer;
    thrd: TKqueueWorkerThread;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);

    for i:= 0 to poolSize - 1 do
    begin
        thrd := TKqueueWorkerThread.create(
           SUSPENDED,
           aKqFd,
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

function initListenFd(kqFd: longint; aport:word) : longint;
var
    addr: sockaddr_in;
    fd: longint;
    listenEv : TKevent;
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

   // need to use edge-triggered so that only one thread get notified
   // when listen socket has something to read
   EV_SET(@listenEv, fd, EVFILT_READ, EV_ADD or EV_ONESHOT, 0, 0, nil);
   if kevent(kqFd, @listenEv, 1, nil, 0, nil) < 0 then
   begin
      exit(ERR_EV_ADD);
   end;
end;

function initExitFd(kqFd : longint) : longint;
var fd: longint;
    exitEv : TKevent;
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
    EV_SET(@exitEv, fd, EVFILT_READ, EV_ADD, 0, 0, nil);
    if kevent(kqFd, @exitEv, 1, nil, 0, nil) < 0 then
    begin
       exit(ERR_EV_ADD);
    end;
end;

function initTimerFd(kqFd, ainterval: longint): longint;
const
     // FPC 3.2.4 does not provide NOTE_SECONDS constant yet so just defined it
     xNOTE_SECONDS = $0001;
     FANO_TIMER_ID = 1;
var
  fd : longint;
  timerEv : TKevent;
begin
    // with kqueue, timer id is just an identifier, so we are free to choose any
    // here we use FANO_TIMER_ID
    fd := FANO_TIMER_ID;
    result := fd;

    EV_SET(@timerEv, fd, EVFILT_TIMER, EV_ADD or EV_ONESHOT, xNOTE_SECONDS, ainterval, nil);
    if kevent(kqFd, @timerEv, 1, nil, 0, nil) < 0 then
    begin
       exit(ERR_EV_ADD);
    end;
end;


function fanoRun(): longint;
var
    aEventFd: longint;
    aListenFd: longint;
    aTimerFd: longint;
    aExitFd: longint;
    ev: array[0..2] of TKevent;
begin
    result := 0;

    // non-zero value is required as epoll_create() failed with 0
    aEventFd := kqueue();

    if aEventFd < 0 then
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
        mainCfg.Timeout,
        mainCfg.cleanIdleConnInterval);

    runThreads(workerThreads);
    waitThreads(workerThreads);
    freeThreads(workerThreads);

    EV_SET(@ev[0], atimerFd, EVFILT_TIMER, EV_DELETE, 0, 0, nil);
    EV_SET(@ev[1], aExitFd, EVFILT_READ, EV_DELETE, 0, 0, nil);
    kevent(aEventFd, @ev, 2, nil, 0, nil);

    // no need to close aExitFd as this will be done automatically
    // in SigTermUtil unit finalization
    // no need to close aTimerFd as it is just and identifier not file descriptor

    fpClose(aListenFd);
    fpClose(aEventFd);
end;
