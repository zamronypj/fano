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
unit EpollWorkerThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   baseunix,
   unix,
   linux,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type


   { TEpollWorkerThread }

   TEpollWorkerThread = class(TDaemonWorkerThread)
   private

        function handleAcceptConn(var ev: epoll_event): TOpStatus;
        function handleClientConn(var ev: epoll_event): TOpStatus;
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
   TimerEpollEvUtil,
   Logger;

const

    MAX_EVENTS = 64;

    // FPC 3.0.4 does not have EPOLLRDHUP yet, so define
    xEPOLLRDHUP = $2000;

function rewatchConn(epollfd: longint; var ev: epoll_event; var isRead, isWrite: boolean): TOpStatus;
var evtBit: cardinal;
begin
    result := default(TOpStatus);

    // important: because EPOLLONESHOT usage, we must re-arm
    // so that next event can be triggered
    // FPC 3.0.4 does not have EPOLLRDHUP yet so use our custom xEPOLLRDHUP
    evtBit := EPOLLET or EPOLLONESHOT or EPOLLERR or EPOLLHUP or xEPOLLRDHUP;

    if isRead then
    begin
        evtBit := evtBit or EPOLLIN;
    end;

    if isWrite then
    begin
        evtBit := evtBit or EPOLLOUT;
    end;

    // important: because EPOLLONESHOT usage, we must re-arm
    // so that next event can be triggered
    ev.events := evtBit;
    if (epoll_ctl(epollfd, EPOLL_CTL_MOD, ev.data.fd, @ev) < 0) then
    begin
        result.error := true;
        result.errCode := SocketError;
        result.errMsg := 'epoll_ctl() EPOLL_CTL_MOD read failed. Fd:'+intToStr(ev.data.fd);
        exit;
    end;
end;


function closeFd(epollfd, fd: longint): TOpStatus;
begin
    result := default(TOpStatus);
    if (epoll_ctl(epollfd, EPOLL_CTL_DEL, fd, nil) < 0) then
    begin
        result.error := true;
        result.errCode := SocketError;
        result.errMsg := 'epoll_ctl() EPOLL_CTL_DEL failed. Fd :'+
            intToStr(fd) + ' Err: ' +
            intToStr(result.errCode);
        exit;
    end;
    fpClose(fd);
end;

function TEpollWorkerThread.closeConnData(var conn: PConnData): TOpStatus;
var connfd: longint;
begin
    result := default(TOpStatus);
    // save connfd as it gets destroyed later
    connfd := conn^.connfd;
    if fireBeforeCloseEv(connfd, conn^.userData) then
    begin
        removeFromConnData(conn, nil, nil);
        result := closeFd(fEventFD, connfd);
    end;
end;


procedure closeAllCallback(connfd: longint; var userData: pointer; callbackData: pointer);
var thrd: TEpollWorkerThread;
    canClose: boolean;
begin
    canClose := true;
    // callbackData will contain instance of TEpollWorkerThread
    thrd := TEpollWorkerThread(callbackData);
    thrd.OnBeforeClose(connfd, userData, canClose);
    // always close no matter what canClose says
    closeFd(thrd.EventFD, connfd);
end;

procedure TEpollWorkerThread.closeAllConn();
begin
    clearConnData(self, @closeAllCallback);
end;

function TEpollWorkerThread.handleAcceptConn(var ev: epoll_event): TOpStatus;
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
        connfd := fpAccept(ev.data.fd, @clnt_addr, @clnt_addr_len);

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
        // epoll event such as associate event with user-defined data
        fireAcceptEv(conn);

        // FPC 3.0.4 does not have EPOLLRDHUP yet so use our custom xEPOLLRDHUP
        connEv.events := EPOLLIN or EPOLLET or EPOLLONESHOT or EPOLLERR or
            EPOLLHUP or xEPOLLRDHUP;
        connEv.data.ptr := conn;

        // add connFd to list of FD we want to watch
        if epoll_ctl(fEventFD, EPOLL_CTL_ADD, connfd, @connEv) < 0 then
        begin
            result.error := true;
            result.errCode := SocketError;
            result.errMsg := 'epoll_ctl() EPOLL_CTL_ADD failed. Conn: '+
                intToStr(connFd) + ' Err: '+
                intToStr(result.errCode);
            exit;
        end;
    end;
end;

function TEpollWorkerThread.handleClientConn(var ev: epoll_event): TOpStatus;
var isEnded, isError: boolean;
    conn: PConnData;
begin
    result := default(TOpStatus);

    conn := PConnData(ev.data.ptr);
    if conn = nil then
    begin
        // very unlikely but in that case just exit and move on
        result.error := true;
        result.errCode := ESysENOMEM;
        result.errMsg := 'handleClientConn() failed. Err: null conn';
        exit;
    end;

    conn^.isRead := (ev.events and EPOLLIN = EPOLLIN);
    conn^.isWrite := (ev.events and EPOLLOUT = EPOLLOUT);
    isEnded := false;
    isError := false;

    // FPC 3.0.4 does not have EPOLLRDHUP yet so use our custom xEPOLLRDHUP
    if (ev.events and EPOLLERR = EPOLLERR) or
       (ev.events and EPOLLHUP = EPOLLHUP) or
       (ev.events and xEPOLLRDHUP = xEPOLLRDHUP) then
    begin
       isError := true;
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
        result := rewatchConn(fEventFd, ev, conn^.isRead, conn^.isWrite);
    end;
end;

procedure cleanIdleConnCallback(connfd: longint; var userData:pointer; callbackData: pointer);
var thrd: TEpollWorkerThread;
    canClose : boolean;
begin
    canClose := true;
    // callbackData will contain instance of TEpollWorkerThread
    thrd := TEpollWorkerThread(callbackData);
    thrd.OnBeforeClose(connfd, userData, canClose);

    // always close no matter what canClose says
    closeFd(thrd.EventFD, connfd);
end;

function TEpollWorkerThread.cleanIdleConn(timeout: longint): TOpStatus;
begin
    result := default(TOpStatus);
    removeTimeoutConnData(timeout, self, @cleanIdleConnCallback);
end;


procedure TEpollWorkerThread.RunLoop();
const WAIT_FOREVER_UNTIL_EV = -1;
var evs: array[0..MAX_EVENTS-1] of epoll_event;
    numFds, i: integer;
    status: TOpStatus;

    procedure initEvs();
    var i: integer;
    begin
        for i:=0 to MAX_EVENTS - 1 do
        begin
            evs[i] := default(epoll_event);
        end;
    end;

begin
    initEvs();
    while (true) do
    begin
        // wait without timeout. We will close idle connections
        // using timer_fd
        numFds := epoll_wait(fEventFD, @evs, MAX_EVENTS, WAIT_FOREVER_UNTIL_EV);

        if numFds < 0 then
        begin
            if errno = ESysEINTR then
            begin
                // signal interruption, not fatal so retry
                continue;
            end else
            begin
                // fatal error, e.g. EABDF, EINVAL, EFAULT
                logErr('epoll_wait() failed Err:' + intToStr(errno));
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
            if (evs[i].data.fd = fListenFD) and ((evs[i].events AND EPOLLIN) = EPOLLIN) then
            begin
                {$IFDEF VERBOSE}
                log('Accept');
                {$ENDIF}

                // if we get here meaning we get new client connection
                // accept it
                status := handleAcceptConn(evs[i]);

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
            if (evs[i].data.fd = fTimerFd)  and ((evs[i].events AND EPOLLIN) = EPOLLIN) then
            begin
                {$IFDEF VERBOSE}
                log('Timer event triggered');
                {$ENDIF}
                cleanIdleConn(fTimeout);
                // we dont need timer data but
                // it is important to read all data because of EPOLLET
                // otherwise event will keep trigger and eating CPU usage
                if readDiscardAll(evs[i].data.fd) < 0 then
                begin
                   // err read timer
                   logErr('Read timer event failed');
                   exit;
                end;
                // ensure to rearm timerfd
                modTimerEv(fEventFd, evs[i].data.fd);
            end else
            if (evs[i].data.fd = fExitFd) and ((evs[i].events AND EPOLLIN) = EPOLLIN) then
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
