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
   aListenFd, aExitFd,
   aTimerFd,
   aClosePipeInFd, aClosePipeOutFd,
   atimeout: longint;
   aCleanIdleConnInterval: integer);
const SUSPENDED = true;
var i: integer;
    selthrd : TSelectWorkerThread;
    thrd: TDaemonWorkerThread;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    // create one dedicated thread for select() and rest are conn worker threads
    selthrd := TSelectWorkerThread.create(
       SUSPENDED,
       aListenFd,
       aExitFd,
       aTimerFd,
       aClosePipeInFd,
       atimeout,
       aCleanIdleConnInterval
    );

    {$IF DEFINED(FASTCGI)}
    selthrd.onAccepted := @FastCgiProcessor.OnAccepted;
    selthrd.OnBeforeClose := @FastCgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(SCGI)}
    selthrd.onAccepted := @ScgiProcessor.OnAccepted;
    selthrd.OnBeforeClose := @ScgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(UWSGI)}
    selthrd.onAccepted := @UwsgiProcessor.OnAccepted;
    selthrd.OnBeforeClose := @UwsgiProcessor.OnBeforeClose;
    {$ELSEIF DEFINED(HTTP2)}
    selthrd.onAccepted := @Http2Processor.OnAccepted;
    selthrd.OnBeforeClose := @Http2Processor.OnBeforeClose;
    {$ELSE}
    selthrd.onAccepted := @HttpProcessor.OnAccepted;
    selthrd.OnBeforeClose := @HttpProcessor.OnBeforeClose;
    {$ENDIF}

    aWorkerThreads[0] := selthrd;

    for i:= 1 to poolSize - 1 do
    begin
        thrd := TConnProcessorThread.create(
           SUSPENDED,
           aListenFd,
           aExitFd,
           aTimerFd,
           aClosePipeOutFd,
           atimeout,
           aCleanIdleConnInterval
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

   selthrd.workerThreads := aWorkerThreads;
end;

function initListenFd(aport:word) : longint;
var
    addr: sockaddr_in;
    fd: longint;
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

end;

function initExitFd() : longint;
var fd: longint;
begin
    fd := getExitFd();
    result := fd;

    if fd < 0 then
    begin
        // todo: error handling
        writeln('exit fd failed');
        exit;
    end;
end;


function initTimerFd(ainterval: integer): longint;
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

end;

function initCloseFd(var pipeInFd, pipeOutFd: longint): longint;
const
    ERR_PIPE_IN = -1;
    ERR_PIPE_OUT = -2;
begin
    AssignPipe(pipeInFd, pipeOutFd);
    if  pipeInFd < 0 then
    begin
        exit(ERR_PIPE_IN);
    end;
    if  pipeOutFd < 0 then
    begin
        exit(ERR_PIPE_OUT);
    end;
    setNonBlocking(pipeInFd);
    setNonBlocking(pipeOutFd);
end;

function fanoRun(): longint;
var
    aListenFd: longint;
    aTimerFd: longint;
    aExitFd: longint;
    aClosePipeInFd: longint;
    aClosePipeOutFd: longint;
begin
    result := 0;

    aListenFd := initListenFd(mainCfg.Port);
    if aListenFd < 0 then
    begin
       // todo: error handling
       exit;
    end;

    aTimerFd := initTimerFd(mainCfg.CleanIdleConnInterval);
    if aTimerFd < 0 then
    begin
       // todo: error handling
       logErr('error set timer Err: ' + intToStr(errno));
       exit;
    end;

    aExitFd := initExitFd();
    if aExitFd < 0 then
    begin
       // todo: error handling
       exit;
    end;

    if initCloseFd(aClosePipeInFd, aClosePipeOutFd) < 0 then
    begin
       // todo: error handling
       exit;
    end;

    createThreads(workerThreads,
        aListenFd,
        aExitFd,
        aTimerFd,
        aClosePipeInFd,
        aClosePipeOutFd,
        mainCfg.Timeout,
        mainCfg.cleanIdleConnInterval);

    runThreads(workerThreads);
    waitThreads(workerThreads);
    freeThreads(workerThreads);

    // no need to close fExitFd as this will be done automatically
    // in SigTermUtil unit finalization
    fpClose(aTimerFd);
    fpClose(aListenFd);
end;
