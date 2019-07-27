{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EpollSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    RunnableIntf,
    RunnableWithDataNotifIntf,
    DataAvailListenerIntf,
    StreamAdapterIntf,
    BaseUnix,
    Unix,
    Linux;

type

    (*!-----------------------------------------------
     * Socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     * This class using Linux epoll API to monitor file descriptors
     *----------------------------------------------------
     * We implement our own socket server because TSocketServer
     * from fcl-net not suitable for handling graceful shutdown
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollSocketSvr = class(TInterfacedObject, IRunnable, IRunnableWithDataNotif)
    private
        procedure raiseExceptionIfAny();

        (*!-----------------------------------------------
         * make file descriptor non blocking
         *-------------------------------------------------
         * @param fd, file descriptor
         *-----------------------------------------------*)
        procedure makeNonBlocking(fd : longint);

        (*!-----------------------------------------------
         * accept all incoming connection until no more pending
         * connection available
         *-------------------------------------------------
         * @param epollFd, file descriptor returned from epoll_create()
         * @param listenSocket, listen socket handle
         *-----------------------------------------------*)
        procedure acceptAllConnections(
            const epollFd : longint;
            const listenSocket : longint
        );

        (*!-----------------------------------------------
         * wait for connection
         *-----------------------------------------------*)
        procedure waitForConnection(
            const epollFd : longint;
            const termPipeIn : longint;
            const listenSocket : longint;
            const events : PEpoll_Event;
            const maxEvents : longint
        );

        (*!-----------------------------------------------
         * called when client connection is established
         *-------------------------------------------------
         * @param clientSocket, socket handle where data can be read
         *-----------------------------------------------*)
        procedure handleClientConnection(clientSocket : longint);

        (*!-----------------------------------------------
         * handle when one or more file descriptor is ready for I/O
         *-------------------------------------------------
         * @param epollFd, file descriptor returned from epoll_create()
         * @param listenSocket, listen socket handle
         * @param pipeIn, terminate pipe input handle
         * @param totFd, total file descriptor ready for I/O
         * @param events, array of TEpoll_Event contained file descriptors
         * @param terminated, set true if we should terminate
         *-----------------------------------------------*)
        procedure handleFileDescriptorIOReady(
            const epollFd : longint;
            const listenSocket : longint;
            const pipeIn : longint;
            const totFd : longint;
            const events : PEpoll_Event;
            var terminated : boolean
        );

        (*!-----------------------------------------------
         * add file descriptor to monitored set
         *-------------------------------------------------
         * @param epollFd, file descriptor returned from epoll_create
         * @param fd, file descriptor to be added
         * @param flag, operation flag
         *-----------------------------------------------*)
        procedure addToMonitoredSet(const epollFd : longint; const fd : longint; const flag : longint);

        (*!-----------------------------------------------
         * remove file descriptor from monitored set
         *-------------------------------------------------
         * @param epollFd, file descriptor returned from epoll_create()
         * @param fd, file descriptor to be removed
         *-----------------------------------------------*)
        procedure removeFromMonitoredSet(const epollFd : longint; const fd : longint);

    protected
        fDataAvailListener : IDataAvailListener;
        fListenSocket : longint;
        fQueueSize : longint;

        (*!-----------------------------------------------
         * bind socket to an socket address
         *-----------------------------------------------*)
        procedure bind(); virtual; abstract;

        (*!-----------------------------------------------
         * begin listen socket
         *-----------------------------------------------*)
        procedure listen(); virtual;

        (*!-----------------------------------------------
         * handle incoming connection until terminated
         *-----------------------------------------------*)
        procedure handleConnection();

        (*!-----------------------------------------------
         * run shutdown sequence
         *-----------------------------------------------*)
        procedure shutdown(); virtual;

        (*!-----------------------------------------------
         * accept connection
         *-------------------------------------------------
         * @param listenSocket, socket handle created with fpSocket()
         * @return client socket which data can be read
         *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; virtual; abstract;

        (*!-----------------------------------------------
         * get stream from socket
         *-------------------------------------------------
         * @param clientSocket, socket handle
         * @return stream of socket
         *-----------------------------------------------*)
        function getSockStream(clientSocket : longint) : IStreamAdapter; virtual;
    public

        (*!-----------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param listenSocket, socket handle created with fpSocket()
         * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
         *-----------------------------------------------*)
        constructor create(listenSocket : longint; queueSize : longint = 5);

        (*!-----------------------------------------------
         * destructor
         *-------------------------------------------------
         * @param listenSocket, socket handle created with fpSocket()
         * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!-----------------------------------------------
         * run socket server until terminated
         *-----------------------------------------------*)
        function run() : IRunnable; virtual;

        (*!------------------------------------------------
         * set instance of class that will be notified when
         * data is available
         *-----------------------------------------------
         * @param dataListener, class that wish to be notified
         * @return true current instance
         *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    end;

implementation

uses

    ESockListenImpl,
    ESockWouldBlockImpl,
    StreamAdapterImpl,
    SockStreamImpl,
    CloseableStreamImpl;

resourcestring

    rsSocketListenFailed = 'Listening failed, error: %d';
    rsAcceptWouldBlock = 'Accept socket would block on socket, error: %d';

type

    TEPoll_EventArr = array [0..0] of TEPoll_Event;
    PEPoll_EventArr = ^TEPoll_EventArr;

var

    //pipe handle that we use to monitor if we get SIGTERM/SIGINT signal
    terminatePipeIn, terminatePipeOut : longInt;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
     *-----------------------------------------------*)
    constructor TEpollSocketSvr.create(listenSocket : longint; queueSize : integer = 5);
    begin
        fListenSocket := listenSocket;
        fQueueSize := queueSize;
        fDataAvailListener := nil;
        makeNonBlocking(listenSocket);
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TEpollSocketSvr.destroy();
    begin
        shutdown();
        inherited destroy();
    end;

    (*!-----------------------------------------------
     * make file descriptor non blocking
     *-------------------------------------------------
     * @param fd, file descriptor
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.makeNonBlocking(fd : longint);
    var flags : longint;
    begin
        //read control flag and set file descriptor to be non blocking
        flags := fpFcntl(fd, F_GETFL, 0);
        fpFcntl(fd, F_SETFl, flags or O_NONBLOCK);
    end;

    (*!-----------------------------------------------
     * begin listen socket
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.listen();
    begin
        if fpListen(fListenSocket, fQueueSize) <> 0 then
        begin
            raise ESockListen.createFmt(rsSocketListenFailed, [ socketError() ]);
        end;
    end;

    procedure TEpollSocketSvr.raiseExceptionIfAny();
    var errno : longint;
    begin
        errno := socketError();
        if (errno = EsockEWOULDBLOCK) or (errno = EsysEAGAIN) then
        begin
            //if we get here, it mostly because socket is non blocking
            //but no pending connection, so just do nothing
        end else
        begin
            //TODO handle error
        end;
    end;

    (*!-----------------------------------------------
     * add file descriptor to monitored set
     *-------------------------------------------------
     * @param epollFd, file descriptor returned from epoll_create
     * @param fd, file descriptor to be added
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.addToMonitoredSet(
        const epollFd : longint;
        const fd : longint;
        const flag : longint
    );
    var ev : TEpoll_Event;
    begin
        ev.events := flag;
        ev.data.fd := fd;
        epoll_ctl(epollFd, EPOLL_CTL_ADD, fd, @ev);
    end;

    (*!-----------------------------------------------
     * remove file descriptor from monitored set
     *-------------------------------------------------
     * @param epollFd, file descriptor returned from epoll_create()
     * @param fd, file descriptor to be removed
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.removeFromMonitoredSet(
        const epollFd : longint;
        const fd : longint
    );
    var ev : TEpoll_Event;
    begin
        //for EPOLL_CTRL_DEL, epoll_event is ignored but
        //due to bug, Linux kernel < 2.6.9 requires non-NULL,
        //here we just give them although not used.
        ev.events := EPOLLIN;
        ev.data.fd := fd;
        epoll_ctl(epollFd, EPOLL_CTL_DEL, fd, @ev);
    end;

    (*!-----------------------------------------------
     * accept all incoming connection until no more pending
     * connection available
     *-------------------------------------------------
     * @param epollFd, file descriptor returned from epoll_create()
     * @param listenSocket, listen socket handle
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.acceptAllConnections(
        const epollFd : longint;
        const listenSocket : longint
    );
    var clientSocket : longint;
    begin
        repeat
            //we have something with listening socket, it means there is
            //new connection coming, accept it
            clientSocket := accept(listenSocket);

            if (clientSocket < 0) then
            begin
                raiseExceptionIfAny();
            end else
            begin
                makeNonBlocking(clientSocket);
                //add client socket to be monitored for I/O read
                addToMonitoredSet(epollFd, clientSocket, EPOLLIN or EPOLLET);
            end;
        until (clientSocket < 0);
    end;


    (*!-----------------------------------------------
     * handle when one or more file descriptor is ready for I/O
     *-------------------------------------------------
     * @param epollFd, file descriptor returned from epoll_create()
     * @param listenSocket, listen socket handle
     * @param pipeIn, terminate pipe input handle
     * @param totFd, total file descriptor ready for I/O
     * @param events, array of TEpoll_Event contained file descriptors
     * @param terminated, set true if we should terminate
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.handleFileDescriptorIOReady(
        const epollFd : longint;
        const listenSocket : longint;
        const pipeIn : longint;
        const totFd : longint;
        const events : PEpoll_Event;
        var terminated : boolean
    );
    var ch : char;
        i, fd, res : longint;
        eventArr : PEPoll_EventArr;
    begin
        //use pointer to array for easier access
        eventArr := PEPoll_EventArr(events);
        for i := 0 to totFd -1  do
        begin
            fd := eventArr^[i].data.fd;
            if (fd = pipeIn) then
            begin
                //we get termination signal, just read until no more
                //bytes and quit
                repeat
                    res := fpRead(pipeIn, @ch, 1);
                until res = ESysEAGAIN;
                terminated := true;
                break;
            end else
            if (fd = listenSocket) then
            begin
                //we have something with listening socket, it means there is
                //new connection coming, accept it
                acceptAllConnections(epollFd, listenSocket);
            end else
            begin
                //if we get here then it must be from one or
                //more client connections
                handleClientConnection(fd);
                removeFromMonitoredSet(epollFd, fd);
            end;
        end;
    end;

    (*!-----------------------------------------------
     * wait for connection
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.waitForConnection(
        const epollFd : longint;
        const termPipeIn : longint;
        const listenSocket : longint;
        const events : PEpoll_Event;
        const maxEvents : longint
    );
    var terminated : boolean;
        totFd : longint;
    begin
        addToMonitoredSet(epollFd, termPipeIn, EPOLLIN or EPOLLET or EPOLLONESHOT);
        addToMonitoredSet(epollFd, listenSocket, EPOLLIN);
        terminated := false;
        repeat
            //wait indefinitely until something happen in fListenSocket or terminatePipeIn
            totFd := epoll_wait(epollFd, events, maxEvents, -1);
            if totFd > 0 then
            begin
                //one or more file descriptors is ready for I/O, check further
                handleFileDescriptorIOReady(
                    epollFd,
                    listenSocket,
                    termPipeIn,
                    totFd,
                    events,
                    terminated
                );
            end;
        until terminated;
    end;

    (*!-----------------------------------------------
     * handle incoming connection until terminated
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.handleConnection();
    const MAX_EVENTS = 40;
    var epollFd : longint;
        events : PEpoll_event;
    begin
        epollFd := epoll_create(1024);
        try
            getmem(events, MAX_EVENTS * sizeof(TEpoll_Event));
            try
                waitForConnection(
                    epollFd,
                    terminatePipeIn,
                    fListenSocket,
                    events,
                    MAX_EVENTS
                );
            finally
                freemem(events);
            end;
        finally
            fpClose(epollFd);
        end
    end;

    (*!-----------------------------------------------
     * get stream from socket
     *-------------------------------------------------
     * @param clientSocket, socket handle
     * @return stream of socket
     *-----------------------------------------------*)
    function TEpollSocketSvr.getSockStream(clientSocket : longint) : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TSockStream.create(clientSocket));
    end;

    (*!-----------------------------------------------
     * called when client connection is allowed
     *-------------------------------------------------
     * @param clientSocket, socket handle where data can be read
     *-----------------------------------------------*)
    procedure TEpollSocketSvr.handleClientConnection(clientSocket : longint);
    var aStream : TCloseableStream;
    begin
        if (assigned(fDataAvailListener)) then
        begin
            aStream := TCloseableStream.create(
                clientSocket,
                getSockStream(clientSocket)
            );
            try
                fDataAvailListener.handleData(aStream, self, astream);
            finally
                aStream.free();
            end;
        end;
    end;

    (*!------------------------------------------------
     * set instance of class that will be notified when
     * data is available
     *-----------------------------------------------
     * @param dataListener, class that wish to be notified
     * @return true current instance
    *-----------------------------------------------*)
    function TEpollSocketSvr.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataAvailListener := dataListener;
        result := self;
    end;

    procedure TEpollSocketSvr.shutdown();
    begin
        closeSocket(fListenSocket);
        fDataAvailListener := nil;
    end;

    function TEpollSocketSvr.run() : IRunnable;
    begin
        bind();
        listen();
        handleConnection();
        result := self;
    end;


    (*!-----------------------------------------------
     * signal handler that will be called when
     * SIGTERM, SIGINT and SIGQUIT is received
     *-------------------------------------------------
     * @param sig, signal id i.e, SIGTERM, SIGINT or SIGQUIT
     * @param info, information about signal
     * @param ctx, contex about signal
     *-------------------------------------------------
     * Signal handler must be ordinary procedure
     *-----------------------------------------------*)
    procedure doTerminate(sig : longint; info : PSigInfo; ctx : PSigContext); cdecl;
    var ch : char;
    begin
        //write one byte to mark termination
        ch := '.';
        fpWrite(terminatePipeOut, ch, 1);
    end;

    (*!-----------------------------------------------
     * install signal handler
     *-------------------------------------------------
     * @param aSig, signal id i.e, SIGTERM, SIGINT or SIGQUIT
     *-----------------------------------------------*)
    procedure installTerminateSignalHandler(aSig : longint);
    var oldAct, newAct : SigactionRec;
    begin
        fillChar(newAct, sizeOf(SigactionRec), #0);
        fillChar(oldAct, sizeOf(Sigactionrec), #0);
        newAct.sa_handler := @doTerminate;
        fpSigaction(aSig, @newAct, @oldAct);
    end;

    procedure makePipeNonBlocking(termPipeIn: longint; termPipeOut : longint);
    var flags : integer;
    begin
        //read control flag and set pipe in to be non blocking
        flags := fpFcntl(termPipeIn, F_GETFL, 0);
        fpFcntl(termPipeIn, F_SETFl, flags or O_NONBLOCK);

        //read control flag and set pipe out to be non blocking
        flags := fpFcntl(termPipeOut, F_GETFL, 0);
        fpFcntl(termPipeOut, F_SETFl, flags or O_NONBLOCK);
    end;

initialization

    //setup non blocking pipe to use for signal handler.
    //Need to be done before install handler to prevent race condition
    assignPipe(terminatePipeIn, terminatePipeOut);
    makePipeNonBlocking(terminatePipeIn, terminatePipeOut);

    //install signal handler after pipe setup
    installTerminateSignalHandler(SIGTERM);
    installTerminateSignalHandler(SIGINT);
    installTerminateSignalHandler(SIGQUIT);

finalization

    fpClose(terminatePipeIn);
    fpClose(terminatePipeOut);

end.
