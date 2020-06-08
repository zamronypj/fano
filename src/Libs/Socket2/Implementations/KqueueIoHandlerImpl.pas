{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit KqueueIoHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    IoHandlerIntf,
    DataAvailListenerIntf,
    ListenSocketIntf,
    StreamAdapterIntf,
    AbstractIoHandlerImpl,
    BaseUnix,
    Unix,
    Bsd;

type

    (*!-----------------------------------------------
     * I/O handler implementation using BSD kqueue API
     * to monitor file descriptors
     *------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TKqueueIoHandler = class(TAbstractIoHandler)
    private
        fTimeoutVal : longint;

        (*!-----------------------------------------------
         * accept all incoming connection until no more pending
         * connection available
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param listenSocket, listen socket
         *-----------------------------------------------*)
        procedure acceptAllConnections(
            const kqFd : longint;
            const listenSocket : IListenSocket
        );

        (*!-----------------------------------------------
         * wait for connection
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param termPipeIn, terminate pipe in
         * @param listenSocket, listen socket
         * @param events, array of TEpoll_Event contained file descriptors
         * @param maxEvent, total item in events array
         *-----------------------------------------------*)
        procedure waitForConnection(
            const kqFd : longint;
            const termPipeIn : longint;
            const listenSocket : IListenSocket;
            const events : PEpoll_Event;
            const maxEvents : longint
        );

        (*!-----------------------------------------------
         * run wait for connection loop
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param listenSocket, listen socket
         * @param termPipeIn, terminate pipe in
         *-----------------------------------------------*)
        procedure runWaitConnection(
            const kqFd : longint;
            const listenSocket :IListenSocket;
            const termPipeIn : longint
        );

        (*!-----------------------------------------------
         * called when client connection is established
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param clientSocket, socket handle where data can be read
         *-----------------------------------------------*)
        function handleClientConnection(
            const kqFd : longint;
            const clientSocket : longint
        ) : boolean;

        (*!-----------------------------------------------
         * handle when one or more file descriptor is ready for I/O
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param listenSocket, listen socket handle
         * @param pipeIn, terminate pipe input handle
         * @param totFd, total file descriptor ready for I/O
         * @param events, array of TEpoll_Event contained file descriptors
         * @param terminated, set true if we should terminate
         *-----------------------------------------------*)
        procedure handleFileDescriptorIOReady(
            const kqFd : longint;
            const listenSocket : IListenSocket;
            const pipeIn : longint;
            const totFd : longint;
            const events : PEpoll_Event;
            var terminated : boolean
        );

        (*!-----------------------------------------------
         * add file descriptor to monitored set
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param fd, file descriptor to be added
         * @param flag, operation flag
         *-----------------------------------------------*)
        procedure addToMonitoredSet(const kqFd : longint; const fd : longint; const flag : cardinal);

        (*!-----------------------------------------------
         * remove file descriptor from monitored set
         *-------------------------------------------------
         * @param kqFd, file descriptor returned from kqueue()
         * @param fd, file descriptor to be removed
         *-----------------------------------------------*)
        procedure removeFromMonitoredSet(const kqFd : longint; const fd : longint);

    public
        (*!-----------------------------------------------
         * handle incoming connection until terminated
         *------------------------------------------------
         * @param listenSocket listen socket
         * @param termPipeIn termination pipe in file descriptor
         *-----------------------------------------------*)
        procedure handleConnection(const listenSocket : IListenSocket; termPipeIn : longint); override;

    end;

implementation

uses

    CloseableIntf,
    ESockWouldBlockImpl,
    EEpollCreateImpl,
    StreamAdapterImpl,
    SockStreamImpl,
    CloseableStreamImpl,
    EpollCloseableImpl,
    EEpollCtlImpl,
    SocketConsts,
    DateUtils,
    SysUtils,
    Errors,
    StreamIdIntf;

    (*!-----------------------------------------------
     * add file descriptor to monitored set
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue
     * @param fd, file descriptor to be added
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.addToMonitoredSet(
        const kqFd : longint;
        const fd : longint;
        const flag : cardinal
    );
    var ev : TEpoll_Event;
        res : longint;
    begin
        ev.events := flag;
        ev.data.fd := fd;
        res := epoll_ctl(kqFd, EPOLL_CTL_ADD, fd, @ev);
        if (res < 0) then
        begin
            raise EEpollCtl.create(rsEpollAddFileDescriptorFailed);
        end;
    end;

    (*!-----------------------------------------------
     * remove file descriptor from monitored set
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     * @param fd, file descriptor to be removed
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.removeFromMonitoredSet(
        const kqFd : longint;
        const fd : longint
    );
    var ev : TEpoll_Event;
    begin
        //for EPOLL_CTRL_DEL, epoll_event is ignored but
        //due to bug, Linux kernel < 2.6.9 requires non-NULL,
        //here we just give them although not used.
        ev.events := EPOLLIN;
        ev.data.fd := fd;
        epoll_ctl(kqFd, EPOLL_CTL_DEL, fd, @ev);
    end;

    (*!-----------------------------------------------
     * accept all incoming connection until no more pending
     * connection available
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     * @param listenSocket, listen socket handle
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.acceptAllConnections(
        const kqFd : longint;
        const listenSocket : IListenSocket
    );
    var clientSocket : longint;
    begin
        repeat
            //we have something with listening socket, it means there is
            //new connection coming, accept it
            clientSocket := listenSocket.accept(listenSocket.fd);

            if (clientSocket < 0) then
            begin
                handleAcceptError();
            end else
            begin
                //TODO : improve FCGI parser so we can use non blocking socket
                //Turn off for now as our FCGI parser not suitable for
                //handling non blocking socket
                fSockOpts.makeNonBlocking(clientSocket);

                //add client socket to be monitored for I/O read
                //note that before client socket is closed,
                //we will remove it from monitored set (see TEpollCloseable class)
                addToMonitoredSet(kqFd, clientSocket, EPOLLIN or EPOLLET);
            end;
        until (clientSocket < 0);
    end;

    (*!-----------------------------------------------
     * handle when one or more file descriptor is ready for I/O
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     * @param listenSocket, listen socket handle
     * @param pipeIn, terminate pipe input handle
     * @param totFd, total file descriptor ready for I/O
     * @param events, array of TEpoll_Event contained file descriptors
     * @param terminated, set true if we should terminate
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.handleFileDescriptorIOReady(
        const kqFd : longint;
        const listenSocket : IListenSocket;
        const pipeIn : longint;
        const totFd : longint;
        const events : PEpoll_Event;
        var terminated : boolean
    );
    var i, fd : longint;
    begin
        for i := 0 to totFd -1  do
        begin
            fd := events[i].data.fd;
            if (fd = pipeIn) then
            begin
                readPipe(pipeIn);
                terminated := true;
                break;
            end else
            if (fd = listenSocket.fd) then
            begin
                //we have something with listening socket, it means there is
                //new connection coming, accept it
                acceptAllConnections(kqFd, listenSocket);
            end else
            begin
                //if we get here then it must be from one or
                //more client connections
                handleClientConnection(kqFd, fd);
            end;
        end;
    end;

    (*!-----------------------------------------------
     * wait for connection
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     * @param termPipeIn, terminate pipe in
     * @param listenSocket, listen socket
     * @param events, array of TEpoll_Event contained file descriptors
     * @param maxEvent, total item in events array
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.waitForConnection(
        const kqFd : longint;
        const termPipeIn : longint;
        const listenSocket : IListenSocket;
        const events : PEpoll_Event;
        const maxEvents : longint
    );
    var terminated : boolean;
        totFd : longint;
    begin
        addToMonitoredSet(kqFd, termPipeIn, EPOLLIN);
        addToMonitoredSet(kqFd, listenSocket.fd, EPOLLIN);
        try
            terminated := false;
            repeat
                //wait indefinitely until something happen in fListenSocket or epollTerminatePipeIn
                totFd := epoll_wait(kqFd, events, maxEvents, fTimeoutVal);
                if totFd > 0 then
                begin
                    //one or more file descriptors is ready for I/O, check further
                    handleFileDescriptorIOReady(
                        kqFd,
                        listenSocket,
                        termPipeIn,
                        totFd,
                        events,
                        terminated
                    );
                end else
                if (totFd = 0) then
                begin
                    //timeout reached.
                    //For now, do nothing
                end else
                if (totFd < 0) then
                begin
                    //we have error just terminate
                    terminated := true;
                end;
            until terminated;
        finally
            removeFromMonitoredSet(kqFd, termPipeIn);
            removeFromMonitoredSet(kqFd, listenSocket.fd);
        end;
    end;

    (*!-----------------------------------------------
     * run wait for connection loop
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.runWaitConnection(
        const kqFd : longint;
        const listenSocket : IListenSocket;
        const termPipeIn : longint
    );
    const MAX_EVENTS = 64;
    var events : PEpoll_event;
    begin
        getmem(events, MAX_EVENTS * sizeof(TEpoll_Event));
        try
            waitForConnection(
                kqFd,
                termPipeIn, //global pipe for terminate
                listenSocket,
                events,
                MAX_EVENTS
            );
        finally
            freemem(events);
        end;
    end;

    (*!-----------------------------------------------
     * handle incoming connection until terminated
     *-------------------------------------------------
     * @throws EEpollCreate exception
     *-----------------------------------------------*)
    procedure TKqueueIoHandler.handleConnection(const listenSocket : IListenSocket; termPipeIn : longint);
    var kqFd : longint;
    begin
        kqFd := kqueue();

        if (kqFd < 0) then
        begin
            raise EEpollCreate.create(rsEpollInitFailed);
        end;

        try
            runWaitConnection(kqFd, listenSocket, termPipeIn);
        finally
            fpClose(kqFd);
        end;
    end;

    (*!-----------------------------------------------
     * called when client connection is allowed
     *-------------------------------------------------
     * @param kqFd, file descriptor returned from kqueue()
     * @param clientSocket, socket handle where data can be read
     *-----------------------------------------------*)
    function TKqueueIoHandler.handleClientConnection(
        const kqFd : longint;
        const clientSocket : longint
    ) : boolean;
    var astream : IStreamAdapter;
        streamCloser : ICloseable;
    begin
        result := true;
        if (assigned(fDataAvailListener)) then
        begin
            astream := getSockStream(clientSocket);
            try
                //create instance which can remove client socket
                //from epoll monitoring and after that close socket
                streamCloser := TEpollCloseable.create(kqFd, clientSocket);
                try
                    fDataAvailListener.handleData(
                        astream,
                        self,
                        streamCloser,
                        streamCloser as IStreamId
                    );
                finally
                    streamCloser := nil;
                end;
            finally
                astream := nil;
            end;
        end;
    end;

end.
