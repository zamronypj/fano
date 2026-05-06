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
unit KqueueWorkerThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   baseunix,
   unix,
   Bsd,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type


   { TKqueueWorkerThread }

   TKqueueWorkerThread = class(TDaemonWorkerThread)
   private
        function handleAcceptConn(var ev: TKevent): TOpStatus;
        function handleClientConn(var ev: TKevent): TOpStatus;
        function cleanIdleConn(timeout: longint): TOpStatus;
        function closeConnData(var conn: PConnData): TOpStatus;
        procedure closeAllConn();
   protected
        procedure runLoop(); override;
   end;

implementation

uses
   DateUtils,
   NetUtil,
   Logger;

const

    MAX_EVENTS = 64;


function rewatchConn(kqFd, fd: longint; usrData: pointer; var isRead, isWrite: boolean): TOpStatus;
var ev: array[0..1] of TKevent;
    indx: integer;
begin
    result := default(TOpStatus);
    indx := 0;
    if isRead then
    begin
        EV_SET(@ev[indx], fd, EVFILT_READ, EV_ADD or EV_ENABLE or EV_ONESHOT, 0, 0, usrData);
        inc(indx);
    end;

    if isWrite then
    begin
        EV_SET(@ev[indx], fd, EVFILT_WRITE, EV_ADD or EV_ENABLE or EV_ONESHOT, 0, 0, usrData);
        inc(indx);
    end;

    if indx = 0 then
    begin
        exit;
    end;

    if kevent(kqFd, @ev, indx, nil, 0, nil) < 0 then
    begin
        result.error := true;
        result.errCode := SocketError;
        result.errMsg := 'rewatchConn kevent() EV_ADD failed. Fd :'+
            intToStr(fd) + ' Err: ' +
            intToStr(result.errCode);
        exit;
    end;
end;

function rewatchTimer(kqFd, fd:longint; ainterval: integer): TOpStatus;
// FPC 3.2.4 does not provide NOTE_SECONDS constant yet so just defined it
const xNOTE_SECONDS = $0001;
var ev: TKevent;
begin
    result := default(TOpStatus);
    EV_SET(@ev, fd, EVFILT_TIMER, EV_ADD or EV_ONESHOT, xNOTE_SECONDS, ainterval, nil);
    if kevent(kqFd, @ev, 1, nil, 0, nil) < 0 then
    begin
        result.error := true;
        result.errCode := SocketError;
        result.errMsg := 'rewatchTimer kevent() EV_ADD failed. Fd :'+
            intToStr(fd) + ' Err: ' +
            intToStr(result.errCode);
        exit;
    end;
end;

function TKqueueWorkerThread.closeConnData(var conn: PConnData): TOpStatus;
var connfd: longint;
begin
    result := default(TOpStatus);
    // save connfd as it gets destroyed later
    connfd := conn^.connfd;
    if fireBeforeCloseEv(connfd, conn^.userData) then
    begin
        removeFromConnData(conn, nil, nil);
        fpClose(connfd);
    end;
end;


procedure closeAllCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var thrd: TKqueueWorkerThread;
    canClose: boolean;
begin
    canClose := true;
    // callbackData will contain instance of TKqueueWorkerThread
    thrd := TKqueueWorkerThread(callbackData);
    thrd.OnBeforeClose(connfd, userData, canClose);
    // always close no matter what canClose says
    fpClose(connfd);
end;

procedure TKqueueWorkerThread.closeAllConn();
begin
    clearConnData(self, @closeAllCallback);
end;

function TKqueueWorkerThread.handleAcceptConn(var ev: TKevent): TOpStatus;
var clnt_addr: sockaddr_in;
    clnt_addr_len : socklen_t;
    connfd, err: longint;
    connEv: TKevent;
    conn: PConnData;
begin
    result := default(TOpStatus);
    while true do
    begin
        clnt_addr := default(sockaddr_in);
        clnt_addr_len := sizeof(clnt_addr);

        // if we get here we can assume ev.indent = fListenFD
        connfd := fpAccept(ev.ident, @clnt_addr, @clnt_addr_len);

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

        conn := addFdToConnData(connfd, nil, nil);
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
        // event such as associate event with user-defined data
        fireAcceptEv(conn);

        // add connFd to list of FD we want to watch and we want to read first
        EV_SET(@connEv, connfd, EVFILT_READ, EV_ADD or EV_ONESHOT, 0, 0, conn);
        if kevent(fEventFd, @connEv, 1, nil, 0, nil) < 0 then
        begin
            result.error := true;
            result.errCode := SocketError;
            result.errMsg := 'watch client conn EV_ADD failed. Fd :'+
                intToStr(connfd) + ' Err: ' +
                intToStr(result.errCode);
            exit;
        end;
    end;
end;

function TKqueueWorkerThread.handleClientConn(var ev: TKevent): TOpStatus;
var isEnded, isError: boolean;
    conn: PConnData;
begin
    result := default(TOpStatus);

    conn := PConnData(ev.uData);
    if conn = nil then
    begin
        // very unlikely but in that case just exit and move on
        result.error := true;
        result.errCode := ESysENOMEM;
        result.errMsg := 'handleClientConn() failed. Err: null conn';
        exit;
    end;

    conn^.isRead := (ev.filter = EVFILT_READ);
    conn^.isWrite := (ev.filter = EVFILT_WRITE);
    isEnded := false;
    isError := false;

    if (ev.flags and EV_ERROR = EV_ERROR) then
    begin
       isError := true;
       closeConnData(conn);
       exit;
    end;

    if (ev.flags and EV_EOF = EV_EOF) then
    begin
       isEnded := true;
       closeConnData(conn);
       exit;
    end;

    // keep track of connection last activity
    touchConnData(conn);

    // let caller read/or write and also decide if
    // we should continue read or write or close connection
    fireDataAvailEv(conn, conn^.isRead, conn^.isWrite, isEnded, isError);

    if isError or isEnded then
    begin
        if isError then
        begin
            logErr('Read data failed');
        end;
        result := closeConnData(conn);
    end else
    begin
        result := rewatchConn(fEventFd, conn^.connfd, conn^.userData, conn^.isRead, conn^.isWrite);
    end;
end;

procedure cleanIdleConnCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var thrd: TKqueueWorkerThread;
    canClose : boolean;
begin
    canClose := true;
    // callbackData will contain instance of TKqueueWorkerThread
    thrd := TKqueueWorkerThread(callbackData);
    thrd.OnBeforeClose(connfd, userData, canClose);

    // always close no matter what canClose says
    fpClose(connfd);
end;

function TKqueueWorkerThread.cleanIdleConn(timeout: longint): TOpStatus;
begin
    result := default(TOpStatus);
    removeTimeoutConnData(timeout, self, @cleanIdleConnCallback);
end;


procedure TKqueueWorkerThread.RunLoop();
const WAIT_FOREVER_UNTIL_EV = nil;
var evs: array[0..MAX_EVENTS-1] of TKevent;
    numFds, i: integer;
    status: TOpStatus;
    listenEv: TKevent;

    procedure initEvs();
    var i: integer;
    begin
        for i:=0 to MAX_EVENTS - 1 do
        begin
            evs[i] := default(TKevent);
        end;
    end;

begin
    initEvs();
    while (true) do
    begin
        // wait without timeout. We will close idle connections
        // using timer_fd
        numFds := kevent(fEventFD, nil, 0, @evs, MAX_EVENTS, WAIT_FOREVER_UNTIL_EV);

        if numFds < 0 then
        begin
            if errno = ESysEINTR then
            begin
                // signal interruption, not fatal so retry
                continue;
            end else
            begin
                // fatal error, e.g. EABDF, EINVAL, EFAULT
                logErr('kevent() wait failed Err:' + intToStr(errno));
                exit;
            end;
        end;

        if numFds = 0 then
        begin
            {$IFDEF VERBOSE}
            log('Clean up idle connection');
            {$ENDIF}
            cleanIdleConn(fTimeout);
            continue;
        end;

        // if we get here we have something ready for I/O
        for i := 0 to numFds - 1 do
        begin
            if (evs[i].ident = fListenFD) and (evs[i].filter = EVFILT_READ) then
            begin
                {$IFDEF VERBOSE}
                log('Accept');
                {$ENDIF}

                // if we get here meaning we get new client connection
                // accept it
                status := handleAcceptConn(evs[i]);

                // rearm listenFd otherwise we never receive another one
                EV_SET(@listenEv, fListenFd, EVFILT_READ, EV_ADD or EV_ONESHOT, 0, 0, nil);
                if kevent(fEventFD, @listenEv, 1, nil, 0, nil) < 0 then
                begin
                    logErr('rearm listen fd failed');
                    // exit because there is no point if we can not accept anymore
                    exit;
                end;

                if status.wouldBlocked then
                begin
                   // can not accept at the moment, lets try later
                   // for now just process next event
                   continue;
                end;

                if status.error then
                begin
                   // accept error, log it and give up
                   // and just process next event
                   logErr(status.errMsg);
                   continue;
                end;


            end else
            if (evs[i].ident = fTimerFd)  and (evs[i].filter = EVFILT_TIMER) then
            begin
                {$IFDEF VERBOSE}
                log('Timer event triggered');
                {$ENDIF}
                cleanIdleConn(fTimeout);
                // ensure to rearm timerfd
                rewatchTimer(fEventFd, evs[i].ident, fCleanIdleConnInterval);
            end else
            if (evs[i].ident = fExitFd) and (evs[i].filter = EVFILT_READ) then
            begin
                // termination is requested,
                // no need to read fd to ensure that all threads notified
                {$IFDEF VERBOSE}
                log('Shutdown event triggered');
                {$ENDIF}
                closeAllConn();
                exit();
            end else
            begin
                // if we get here meaning we get data
                // need to read from client or write to client
                {$IFDEF VERBOSE}
                log('Incoming client data');
                {$ENDIF}
                status := handleClientConn(evs[i]);
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


end.
