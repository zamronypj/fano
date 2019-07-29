{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SocketSvrImpl;

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
    Unix;

type

    (*!-----------------------------------------------
     * Socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *----------------------------------------------------
     * We implement our own socket server because TSocketServer
     * from fcl-net not suitable for handling graceful shutdown
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSocketSvr = class(TInterfacedObject, IRunnable, IRunnableWithDataNotif)
    private
        procedure raiseExceptionIfAny();

        (*!-----------------------------------------------
         * make listen socket non blocking
         *-------------------------------------------------
         * @param listenSocket, listen socket handle
         *-----------------------------------------------*)
        procedure makeNonBlockingSocket(listenSocket : longint);

        (*!-----------------------------------------------
         * accept all incoming connection until no more pending
         * connection available
         *-------------------------------------------------
         * @param listenSocket, listen socket handle
         * @param maxHandle, highest handle
         * @param origFds, original file descriptor set
         *-----------------------------------------------*)
        procedure acceptAllConnections(
            const listenSocket : longint;
            var maxHandle : longint;
            var origFds : TFDSet
        );

        (*!-----------------------------------------------
         * called when client connection is established
         *-------------------------------------------------
         * @param clientSocket, socket handle where data can be read
         *-----------------------------------------------*)
        procedure handleClientConnection(clientSocket : longint);

        (*!-----------------------------------------------
         * initialize file descriptor set for listening
         * socket and also termination pipe
         *-------------------------------------------------
         * @param listenSocket, socket handle
         * @param pipeIn, pipe input handle
         * @return file descriptor set
         *-----------------------------------------------*)
        function initFileDescSet(listenSocket : longint; pipeIn : longint) : TFDSet;

        (*!-----------------------------------------------
         * find file descriptor with biggest value
         *-------------------------------------------------
         * @param listenSocket, socket handle
         * @param pipeIn, pipe input handle
         * @return highest handle
         *-----------------------------------------------*)
        function getHighestHandle(listenSocket : longint; pipeIn : longint) : longint;

        (*!-----------------------------------------------
         * handle when one or more file descriptor is ready for I/O
         *-------------------------------------------------
         * @param listenSocket, listen socket handle
         * @param pipeIn, terminate pipe input handle
         * @param readfds, file descriptor set
         * @param totDesc, number of file descriptor ready for I/O
         * @param maxHandle, highest handle
         * @param origFds, original file descriptor set
         * @param terminated, set true if we should terminate
         *-----------------------------------------------*)
        procedure handleFileDescriptorIOReady(
            listenSocket : longint;
            pipeIn : longint;
            const readfds : TFDSet;
            var totDesc : longint;
            var maxHandle : longint;
            var origFds : TFDSet;
            var terminated : boolean
        );

        (*!-----------------------------------------------
         * add client socket to monitored set
         *-------------------------------------------------
         * @param fds, file descriptor to be added
         * @param maxHandle, highest handle
         * @param origFds, original file descriptor set
         *-----------------------------------------------*)
        procedure addToMonitoredSet(
            const fds : longint;
            var maxHandle : longint;
            var origFds : TFDSet
        );

        (*!-----------------------------------------------
         * remove client socket from monitored set
         *-------------------------------------------------
         * @param fds, file descriptor to be removed
         * @param maxHandle, highest handle
         * @param origFds, original file descriptor set
         *-----------------------------------------------*)
        procedure removeFromMonitoredSet(
            const fds : longint;
            var maxHandle : longint;
            var origFds : TFDSet
        );

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
    CloseableStreamImpl,
    TermSignalImpl;

resourcestring

    rsSocketListenFailed = 'Listening failed, error: %d';
    rsAcceptWouldBlock = 'Accept socket would block on socket, error: %d';

// var

//     //pipe handle that we use to monitor if we get SIGTERM/SIGINT signal
//     terminatePipeIn, terminatePipeOut : longInt;
//     oldHandler : SigactionRec;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
     *-----------------------------------------------*)
    constructor TSocketSvr.create(listenSocket : longint; queueSize : integer = 5);
    begin
        fListenSocket := listenSocket;
        fQueueSize := queueSize;
        fDataAvailListener := nil;
        makeNonBlockingSocket(listenSocket);
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TSocketSvr.destroy();
    begin
        shutdown();
        inherited destroy();
    end;

    (*!-----------------------------------------------
     * make listen socket non blocking
     *-------------------------------------------------
     * @param listenSocket, listen socket handle
     *-----------------------------------------------*)
    procedure TSocketSvr.makeNonBlockingSocket(listenSocket : longint);
    var flags : longint;
    begin
        //read control flag and set listen socket to be non blocking
        flags := fpFcntl(listenSocket, F_GETFL, 0);
        fpFcntl(listenSocket, F_SETFl, flags or O_NONBLOCK);
    end;

    (*!-----------------------------------------------
     * begin listen socket
     *-----------------------------------------------*)
    procedure TSocketSvr.listen();
    begin
        if fpListen(fListenSocket, fQueueSize) <> 0 then
        begin
            raise ESockListen.createFmt(rsSocketListenFailed, [ socketError() ]);
        end;
    end;

    (*!-----------------------------------------------
     * initialize file descriptor set for listening
     * socket and also termination pipe
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @param pipeIn, pipe input handle
     * @return file descriptor set
     *-----------------------------------------------*)
    function TSocketSvr.initFileDescSet(listenSocket : longint; pipeIn : longint) : TFDSet;
    begin
        //initialize struct and reset all file descriptors
        result := default(TFDSet);
        fpFD_ZERO(result);

        //add listenSocket to set of read file descriptor we need to monitor
        //so we know if there something happen with listening socket
        fpFD_SET(listenSocket, result);

        //also add terminatePipeIn so we get notified if we get signal to terminate
        fpFD_SET(pipeIn, result);
    end;

    (*!-----------------------------------------------
     * find file descriptor with biggest value
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @param pipeIn, pipe input handle
     * @return highest handle
     *-----------------------------------------------*)
    function TSocketSvr.getHighestHandle(listenSocket : longint; pipeIn : longint) : longint;
    begin
        //find file descriptor with biggest value
        result := 0;
        if (listenSocket > result) then
        begin
            result := listenSocket;
        end;

        if (pipeIn > result) then
        begin
            result := pipeIn;
        end;
    end;

    procedure TSocketSvr.raiseExceptionIfAny();
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
     * @param fds, file descriptor to be added
     * @param maxHandle, highest handle
     * @param origFds, original file descriptor set
     *-----------------------------------------------*)
    procedure TSocketSvr.addToMonitoredSet(
        const fds : longint;
        var maxHandle : longint;
        var origFds : TFDSet
    );
    begin
        fpFD_SET(fds, origFds);
        if fds > maxHandle then
        begin
            maxHandle := fds;
        end;
    end;

    (*!-----------------------------------------------
     * remove file descriptor from monitored set
     *-------------------------------------------------
     * @param fds, file descriptor to be removed
     * @param maxHandle, highest handle
     * @param origFds, original file descriptor set
     *-----------------------------------------------*)
    procedure TSocketSvr.removeFromMonitoredSet(
        const fds : longint;
        var maxHandle : longint;
        var origFds : TFDSet
    );
    begin
        fpFD_CLR(fds, origFds);
        if (fds = maxHandle) then
        begin
            while (fpFD_ISSET(maxHandle, origFds) = 0) do
            begin
                dec(maxHandle);
            end;
        end;
    end;

    (*!-----------------------------------------------
     * accept all incoming connection until no more pending
     * connection available
     *-------------------------------------------------
     * @param listenSocket, listen socket handle
     * @param maxHandle, highest handle
     * @param origFds, original file descriptor set
     *-----------------------------------------------*)
    procedure TSocketSvr.acceptAllConnections(
        const listenSocket : longint;
        var maxHandle : longint;
        var origFds : TFDSet
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
                //add client socket to be monitored for I/O
                addToMonitoredSet(clientSocket, maxHandle, origFds);
            end;
        until (clientSocket < 0);
    end;


    (*!-----------------------------------------------
     * handle when one or more file descriptor is ready for I/O
     *-------------------------------------------------
     * @param listenSocket, listen socket handle
     * @param pipeIn, terminate pipe input handle
     * @param readfds, file descriptor set
     * @param terminated, set true if we should terminate
     *-----------------------------------------------*)
    procedure TSocketSvr.handleFileDescriptorIOReady(
        listenSocket : longint;
        pipeIn : longint;
        const readfds : TFDSet;
        var totDesc : longint;
        var maxHandle : longint;
        var origFds : TFDSet;
        var terminated : boolean
    );
    var ch : char;
        fds : longint;
    begin
        for fds := 0 to maxHandle do
        begin
            if fpFD_ISSET(fds, readfds) > 0 then
            begin
                if fds = pipeIn then
                begin
                    //we get termination signal, just read until no more
                    //bytes and quit
                    fpRead(pipeIn, @ch, 1);
                    terminated := true;
                    break;
                end else
                if fds = listenSocket then
                begin
                    //we have something with listening socket, it means there is
                    //new connection coming, accept it
                    acceptAllConnections(listenSocket, maxHandle, origFds);
                end else
                begin
                    //if we get here then it must be from one or
                    //more client connections
                    handleClientConnection(fds);
                    removeFromMonitoredSet(fds, maxHandle, origFds);
                end;

                dec(totDesc);
                if (totDesc <= 0) then
                begin
                    //if we get here, it means all file descriptors ready for I/O
                    //has been processed, so we can exit loop early
                    break;
                end;
            end;
        end;
    end;

    (*!-----------------------------------------------
     * handle incoming connection until terminated
     *-----------------------------------------------*)
    procedure TSocketSvr.handleConnection();
    var origfds, readfds : TFDSet;
        highestHandle : longint;
        terminated : boolean;
    var totDesc : longint;
    begin
        //find file descriptor with biggest value
        highestHandle := getHighestHandle(fListenSocket, terminatePipeIn);
        origfds := initFileDescSet(fListenSocket, terminatePipeIn);
        terminated := false;
        repeat
            readfds := origfds;

            //wait indefinitely until something happen in fListenSocket or terminatePipeIn
            totDesc := fpSelect(highestHandle + 1, @readfds, nil, nil, nil);
            if totDesc > 0 then
            begin
                //one or more file descriptors is ready for I/O, check further
                handleFileDescriptorIOReady(
                    fListenSocket,
                    terminatePipeIn,
                    readfds,
                    totDesc,
                    highestHandle,
                    origfds,
                    terminated
                );
            end;
        until terminated;
    end;

    (*!-----------------------------------------------
     * get stream from socket
     *-------------------------------------------------
     * @param clientSocket, socket handle
     * @return stream of socket
     *-----------------------------------------------*)
    function TSocketSvr.getSockStream(clientSocket : longint) : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TSockStream.create(clientSocket));
    end;

    (*!-----------------------------------------------
     * called when client connection is allowed
     *-------------------------------------------------
     * @param clientSocket, socket handle where data can be read
     *-----------------------------------------------*)
    procedure TSocketSvr.handleClientConnection(clientSocket : longint);
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
    function TSocketSvr.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataAvailListener := dataListener;
        result := self;
    end;

    procedure TSocketSvr.shutdown();
    begin
        closeSocket(fListenSocket);
        fDataAvailListener := nil;
    end;

    function TSocketSvr.run() : IRunnable;
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
    // procedure doTerminate(sig : longint; info : PSigInfo; ctx : PSigContext); cdecl;
    // var ch : char;
    // begin
    //     //write one byte to mark termination
    //     ch := '.';
    //     fpWrite(terminatePipeOut, ch, 1);
    //     //restore old handler
    //     fpSigaction(sig, @oldHandler, nil);
    //     fpKill(fpGetPid(), sig);
    // end;

    (*!-----------------------------------------------
     * install signal handler
     *-------------------------------------------------
     * @param aSig, signal id i.e, SIGTERM, SIGINT or SIGQUIT
     *-----------------------------------------------*)
    // procedure installTerminateSignalHandler(aSig : longint);
    // var newAct : SigactionRec;
    // begin
    //     fillChar(newAct, sizeOf(SigactionRec), #0);
    //     fillChar(oldHandler, sizeOf(Sigactionrec), #0);
    //     newAct.sa_handler := @doTerminate;
    //     fpSigaction(aSig, @newAct, @oldHandler);
    // end;

    // procedure makePipeNonBlocking(termPipeIn: longint; termPipeOut : longint);
    // var flags : integer;
    // begin
    //     //read control flag and set pipe in to be non blocking
    //     flags := fpFcntl(termPipeIn, F_GETFL, 0);
    //     fpFcntl(termPipeIn, F_SETFl, flags or O_NONBLOCK);

    //     //read control flag and set pipe out to be non blocking
    //     flags := fpFcntl(termPipeOut, F_GETFL, 0);
    //     fpFcntl(termPipeOut, F_SETFl, flags or O_NONBLOCK);
    // end;

initialization

    //setup non blocking pipe to use for signal handler.
    //Need to be done before install handler to prevent race condition
    // assignPipe(terminatePipeIn, terminatePipeOut);
    // makePipeNonBlocking(terminatePipeIn, terminatePipeOut);

    // //install signal handler after pipe setup
    // installTerminateSignalHandler(SIGTERM);
    // installTerminateSignalHandler(SIGINT);
    // installTerminateSignalHandler(SIGQUIT);

finalization

    // fpClose(terminatePipeIn);
    // fpClose(terminatePipeOut);

end.
