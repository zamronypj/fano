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
unit SelectWorkerThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   baseunix,
   unix,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type


   { TSelectWorkerThread }

   TSelectWorkerThread = class(TDaemonWorkerThread)
   private
        fClosePipeInFd: longint;
        fWorkerThreads: TArrThread;
        function handleAcceptConn(alistenFd: longint; var maxFd: longint): TOpStatus;
        function handleClientConn(connfd: longint; var isRead, isWrite: boolean): TOpStatus;
        function cleanIdleConn(timeout: longint): TOpStatus;
        procedure closeAllConn();
   protected
        procedure runLoop(); override;
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
            aMaxBodySize: integer);

        property workerThreads : TArrThread read fWorkerThreads write fWorkerThreads;
        property MaxRequestSize: integer read fMaxRequestSize;
        property MaxBodySize: integer read fMaxBodySize;
   end;

implementation

uses
   DateUtils,
   NetUtil,
   Logger;

{ TSelectWorkerThread }

procedure acceptCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var worker: TSelectWorkerThread;
begin
    worker := TSelectWorkerThread(callbackData);
    worker.OnAccepted(connfd, worker.maxRequestSize, worker.MaxBodySize, userData);
end;

function TSelectWorkerThread.handleAcceptConn(alistenFd: longint; var maxFd : longint): TOpStatus;
var clnt_addr: sockaddr_in;
    clnt_addr_len : socklen_t;
    connfd, err: longint;
    conn: PConnData;
begin
    result := default(TOpStatus);

    clnt_addr := default(sockaddr_in);
    clnt_addr_len := sizeof(clnt_addr);

    // if we get here we can assume ev.data.fd = fListenFD
    connfd := fpAccept(aListenFd, @clnt_addr, @clnt_addr_len);

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

    setNonBlocking(connfd);

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

    {$IFDEF VERBOSE}
    log('accepting client data '+intToStr(connfd));
    {$ENDIF}

    if connfd > maxFd then
    begin
        maxFd := connfd;
    end;
end;

function TSelectWorkerThread.handleClientConn(connfd: longint; var isRead,
  isWrite: boolean): TOpStatus;
var conn: PConnData;
begin
    result := default(TOpStatus);
    conn := pluckConnData(connfd);
    if conn <> nil then
    begin
        conn^.isRead := isRead;
        conn^.isWrite := isWrite;
        enqueueConnData(conn);
    end;
end;

procedure cleanIdleConnCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var thrd: TSelectWorkerThread;
    canClose : boolean;
begin
    canClose := true;
    // callbackData will contain instance of TSelectWorkerThread
    thrd := TSelectWorkerThread(callbackData);
    thrd.OnBeforeClose(connfd, userData, canClose);
    // always close no matter what canClose says
    fpClose(connfd);
end;

function TSelectWorkerThread.cleanIdleConn(timeout: longint): TOpStatus;
begin
    result := default(TOpStatus);
    removeTimeoutConnData(timeout, self, @cleanIdleConnCallback);
end;

type

    PRWFdSet = ^TRWFdSet;
    TRWFdSet = record
        readfds, writefds : TFDSet;
        maxFd: longint;
    end;

procedure addConnToWatch(aConn: PConnData; callbackData: pointer);
var arwFdSet :PRWFdSet;
begin
    arwFdSet := PRWFdSet(callbackData);
    if aConn <> nil then
    begin
        if aConn^.isRead then
        begin
           fpFD_SET(aConn^.connfd, arwFdSet^.readfds);
        end;

        if aConn^.isWrite then
        begin
           fpFD_SET(aConn^.connfd, arwFdSet^.writefds);
        end;

        if aConn^.connfd > arwFdSet^.maxFd then
        begin
            arwFdSet^.maxFd := aConn^.connfd;
        end;
    end;
end;

procedure closeCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var canClose: boolean;
begin
    canClose := true;
    // callbackData will contain instance of TEpollWorkerThread
    TSelectWorkerThread(callbackData).OnBeforeClose(connfd, userData, canClose);
    // always close no matter what canClose says
    if fpClose(connfd) < 0 then
    begin
        logErr('Close conn err ' + intToStr(connfd) + ' errno: ' +intToStr(errno));
    end;
end;

procedure TSelectWorkerThread.closeAllConn();
begin
    clearConnData(self, @closeCallback);
end;

function getMaxFd(aListenFd, aTimerFd, aExitFd, aClosePipeInFd: longint) : longint;
begin
    //find file descriptor with biggest value
    result := 0;
    if (aListenFd > result) then
    begin
        result := aListenFd;
    end;

    if (atimerFd > result) then
    begin
        result := atimerFd;
    end;

    if (aExitFd > result) then
    begin
        result := aExitFd;
    end;

    if (aClosePipeInFd > result) then
    begin
        result := aClosePipeInFd;
    end;
end;

procedure terminateWorkerThreads(workerThreads: TArrThread);
var i: integer;
begin
    // terminate all worker threads, 0 = SelectWorkerThread so start from 1
    for i:= 1 to length(workerThreads) - 1 do
    begin
        workerThreads[i].Terminate;
    end;

    for i:= 1 to length(workerThreads) - 1 do
    begin
        // enqueue dummy data just to wake up ConnThread
        // so it can check terminated status and exit
        enqueueConnData(nil);
    end;

end;



procedure TSelectWorkerThread.runLoop();
var rwFdSet: PRWFdSet;
var fd, totFds: longint;
    isRead, isWrite : boolean;
    status: TOpStatus;
    fdToClose: longint;
    tmpFdToClose : array[0..3] of byte absolute fdToClose;
    tmpFdBytes: longint;


    function readFdToCloseFromPipe(afdToClose:pointer; var atmpFdBytes: longint): boolean;
    var atmpFdBytesRead : longint;
    begin
        result := false;
        while true do
        begin
            atmpFdBytesRead := fpRead(fClosePipeInFd, afdToClose^, sizeof(longint) - atmpFdBytes);
            if atmpFdBytesRead < 0 then
            begin
                if (errno = ESysEAGAIN) or (errno = ESysEWOULDBLOCK) then
                begin
                    // retry later
                    exit(false);
                end;
                logErr('Cannot read close pipe in');
                exit(false);
            end;

            if atmpFdBytesRead >= 0 then
            begin
                inc(atmpFdBytes, atmpFdBytesRead);
                if atmpFdBytes = sizeof(longint) then
                begin
                    exit(true);
                end;
            end;
        end;
    end;

    procedure closeConn(fd: longint);
    begin
        {$IFDEF VERBOSE}
        log('before close conn '+ intToStr(fd));
        {$ENDIF}
        removeFdFromConnData(fd, self, @closeCallback);
        {$IFDEF VERBOSE}
        log('closed conn '+ intToStr(fd));
        {$ENDIF}
    end;

begin
    tmpFdBytes := 0;
    new(rwFdSet);
    try
        rwFdSet^ := default(TRWFDSet);
        while true do
        begin
            //find file descriptor with biggest value
            rwFdSet^.maxFd := getMaxFd(fListenFd, fTimerFd, fExitFd, fClosePipeInFd);

            //need to reset readfds, writefds as they are changed by select()
            fpFD_ZERO(rwFdSet^.readfds);
            fpFD_ZERO(rwFdSet^.writefds);

            fpFD_SET(fListenFd, rwFdSet^.readfds);
            fpFD_SET(fTimerFd, rwFdSet^.readfds);
            fpFD_SET(fExitFd, rwFdSet^.readfds);
            fpFD_SET(fClosePipeInFd, rwFdSet^.readfds);

            traverseConnData(rwFdSet, @addConnToWatch);

            //wait until something happen in
            //listenSocket or termPipeIn or client connection or timer
            totFds := fpSelect(rwFdSet^.maxFd + 1, @rwFdSet^.readfds, @rwFdSet^.writefds, nil, nil);

            if totFds < 0 then
            begin
                if errno = EsysEINTR then
                begin
                    continue;
                end else
                begin
                    // bad thing. just exit and terminate
                    logErr('select() failed. Err ' + intToStr(errno));
                    break;
                end;
            end else
            if totFds = 0 then
            begin
                {$IFDEF VERBOSE}
                log('select() timeout');
                {$ENDIF}
                cleanIdleConn(fTimeout);
            end else
            if totFds > 0 then
            begin
                for fd := 0 to rwFdSet^.maxFd do
                begin
                    if fd = fListenFd then
                    begin
                        if fpFD_ISSET(fListenFd, rwFdSet^.readfds) <> 0 then
                        begin
                            {$IFDEF VERBOSE}
                            log('accept client conn listenfd ' + intToStr(fd));
                            {$ENDIF}
                            status := handleAcceptConn(fListenFd, rwFdSet^.maxFd);
                            if status.error then
                            begin
                                // handle accept error, log it and give up
                                // and just process next event
                                logErr(status.errMsg);
                                continue;
                            end;
                        end;
                    end else
                    if fd = fTimerFd then
                    begin
                        if fpFD_ISSET(fTimerFd, rwFdSet^.readfds) <> 0 then
                        begin
                            {$IFDEF VERBOSE}
                            log('Timer event triggered');
                            {$ENDIF}
                            cleanIdleConn(fTimeout);
                            // we dont need timer data but must read otherwise
                            // it keeps triggering select() is ready
                            if readDiscardAll(fTimerFd) < 0 then
                            begin
                               // err read timer, log error and just moved on
                               logErr('Read timer event failed');
                               continue;
                            end;
                        end;
                    end else
                    if (fd = fExitFd) then
                    begin
                       if (fpFD_ISSET(fExitFd, rwFdSet^.readfds) <> 0) then
                       begin
                           // termination is requested,
                           // no need to read fd to ensure that all threads notified
                           {$IFDEF VERBOSE}
                           log('Shutdown event triggered');
                           {$ENDIF}
                           closeAllConn();
                           exit();
                       end;
                    end else
                    if (fd = fClosePipeInFd) then
                    begin
                       if (fpFD_ISSET(fClosePipeInFd, rwFdSet^.readfds) <> 0) then
                       begin
                          if readFdToCloseFromPipe(@tmpFdToClose[tmpFdBytes], tmpFdBytes) then
                          begin
                              tmpFdBytes := 0;
                              closeConn(fdToClose);
                          end;
                       end;
                    end else
                    if (fpFD_ISSET(fd, rwFdSet^.readfds) <> 0) or
                       (fpFD_ISSET(fd, rwFdSet^.writefds) <> 0) then
                    begin
                        // if we get here meaning we get data
                        // to read from client or write to client
                        {$IFDEF VERBOSE}
                        log('Incoming client data '+intToStr(fd));
                        {$ENDIF}
                        isRead := (fpFD_ISSET(fd, rwFdSet^.readfds) <> 0);
                        isWrite := (fpFD_ISSET(fd, rwFdSet^.writefds) <> 0);
                        status := handleClientConn(fd, isRead, isWrite);
                        if status.error then
                        begin
                            // handle client error, log it and give up
                            // and just process next event
                            logErr(status.errMsg);
                            continue;
                        end;
                    end;
                end;
            end;
        end;

    finally
        dispose(rwFdSet);
        terminateWorkerThreads(fWorkerThreads);
    end;
end;

constructor TSelectWorkerThread.Create(aSuspended: boolean;
  aListenFd: longint; aExitFd: longint; aTimerFd: longint;
  aClosePipeInFd: longint; aTimeout: longint;
  aCleanIdleConnInterval,
  aMaxRequestSize,
  aMaxBodySize: integer);
begin
    inherited Create(aSuspended, 0, aListenFd, aExitFd, aTimerFd, aTImeout,
       aCleanIdleConnInterval,
       aMaxRequestSize,
       aMaxBodySize);
    fClosePipeInFd := aClosePipeInFd;
end;


end.
