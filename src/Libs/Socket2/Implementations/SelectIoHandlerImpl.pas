{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SelectIoHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    IoHandlerIntf,
    DataAvailListenerIntf,
    StreamAdapterIntf,
    BaseUnix,
    Unix;

type

    (*!-----------------------------------------------
     * I/O handler implementation which use select()
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSelectIoHandler = class(TInterfacedObject, IIoHandler)
    private
        procedure raiseExceptionIfAny();

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
        function handleClientConnection(clientSocket : longint) : boolean;

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

        (*!-----------------------------------------------
         * convert timeout in millisecond to TTimeVal record
         *-------------------------------------------------
         * @param timeoutInMs, timeout in millisecond
        *-----------------------------------------------*)
        function getTimeout(const timeoutInMs : integer) : TTimeVal;

    protected
        fDataAvailListener : IDataAvailListener;
        fIdleTimeout : longint;
        fTimeoutVal : TTimeVal;


        (*!-----------------------------------------------
         * get stream from socket
         *-------------------------------------------------
         * @param clientSocket, socket handle
         * @return stream of socket
         *-----------------------------------------------*)
        function getSockStream(clientSocket : longint) : IStreamAdapter; virtual;

    public
        (*!-----------------------------------------------
         * handle incoming connection until terminated
         *-----------------------------------------------*)
        procedure handleConnection(listenSocket : longint; termPipeIn : longint);

        (*!------------------------------------------------
         * set instance of class that will be notified when
         * data is available
         *-----------------------------------------------
         * @param dataListener, class that wish to be notified
         * @return true current instance
         *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IIoHandler;
    end;

implementation

uses

    SysUtils,
    Errors,
    SocketConsts,
    ESockListenImpl,
    ESockWouldBlockImpl,
    ESockErrorImpl,
    StreamAdapterImpl,
    SockStreamImpl,
    CloseableStreamImpl,
    TermSignalImpl,
    DateUtils;


    (*!-----------------------------------------------
     * initialize file descriptor set for listening
     * socket and also termination pipe
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @param pipeIn, pipe input handle
     * @return file descriptor set
     *-----------------------------------------------*)
    function TSelectIoHandler.initFileDescSet(listenSocket : longint; pipeIn : longint) : TFDSet;
    begin
        //initialize struct and reset all file descriptors
        result := default(TFDSet);
        fpFD_ZERO(result);

        //add listenSocket to set of read file descriptor we need to monitor
        //so we know if there something happen with listening socket
        fpFD_SET(listenSocket, result);

        //also add termPipeIn so we get notified if we get signal to terminate
        fpFD_SET(pipeIn, result);
    end;

    (*!-----------------------------------------------
     * find file descriptor with biggest value
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @param pipeIn, pipe input handle
     * @return highest handle
     *-----------------------------------------------*)
    function TSelectIoHandler.getHighestHandle(listenSocket : longint; pipeIn : longint) : longint;
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

    procedure TSelectIoHandler.raiseExceptionIfAny();
    var errCode : longint;
    begin
        errCode := socketError();
        if (errCode = ESysEWOULDBLOCK) or (errCode = ESysEAGAIN) then
        begin
            //if we get here, it mostly because socket is non blocking
            //but no pending connection, so just do nothing
        end else
        begin
            raise ESockError.createFmt(
                rsSocketError,
                errCode,
                strError(errCode)
            );
        end;
    end;

    (*!-----------------------------------------------
     * add file descriptor to monitored set
     *-------------------------------------------------
     * @param fds, file descriptor to be added
     * @param maxHandle, highest handle
     * @param origFds, original file descriptor set
     *-----------------------------------------------*)
    procedure TSelectIoHandler.addToMonitoredSet(
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
    procedure TSelectIoHandler.removeFromMonitoredSet(
        const fds : longint;
        var maxHandle : longint;
        var origFds : TFDSet
    );
    begin
        fpFD_CLR(fds, origFds);
        if (fds = maxHandle) then
        begin
            //if we get here then we remove biggest file descriptor,
            //update maxHandle to lower biggest file descriptor in set
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
    procedure TSelectIoHandler.acceptAllConnections(
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
                makeNonBlockingSocket(clientSocket);
                //add client socket to be monitored for I/O
                addToMonitoredSet(clientSocket, maxHandle, origFds);
                {$IFDEF CLOSE_IDLE_CONNECTIONS}
                addToConnectionsQueue(clientSocket);
                {$ENDIF}
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
    procedure TSelectIoHandler.handleFileDescriptorIOReady(
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
                    if handleClientConnection(fds) then
                    begin
                        removeFromMonitoredSet(fds, maxHandle, origFds);
                    end;
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
     * convert timeout in millisecond to TTimeVal record
     *-------------------------------------------------
     * @param timeoutInMs, timeout in millisecond
     *-----------------------------------------------*)
    function TSelectIoHandler.getTimeout(const timeoutInMs : integer) : TTimeVal;
    begin
        //get microsecond from millisecond
        result.tv_usec := (timeoutInMs mod 1000) * 1000;
        //get seconds from millisecond
        result.tv_sec := timeoutInMs div 1000;
    end;

    (*!-----------------------------------------------
     * handle incoming connection until terminated
     *-----------------------------------------------*)
    procedure TSelectIoHandler.handleConnection(listenSocket : longint; termPipeIn : longint);
    var origfds, readfds : TFDSet;
        highestHandle : longint;
        terminated : boolean;
    var totDesc : longint;
    begin
        //find file descriptor with biggest value
        highestHandle := getHighestHandle(listenSocket, termPipeIn);
        origfds := initFileDescSet(listenSocket, termPipeIn);
        terminated := false;
        repeat
            readfds := origfds;
            //wait until something happen in
            //listenSocket or termPipeIn or client connection or timeout
            totDesc := fpSelect(highestHandle + 1, @readfds, nil, nil, @fTimeoutVal);
            if totDesc > 0 then
            begin
                //one or more file descriptors is ready for I/O, check further
                handleFileDescriptorIOReady(
                    listenSocket,
                    termPipeIn,
                    readfds,
                    totDesc,
                    highestHandle,
                    origfds,
                    terminated
                );
            end;
            {$IFDEF CLOSE_IDLE_CONNECTIONS}
            closeIdleConnections();
            {$ENDIF}
        until terminated;
    end;

    (*!-----------------------------------------------
     * get stream from socket
     *-------------------------------------------------
     * @param clientSocket, socket handle
     * @return stream of socket
     *-----------------------------------------------*)
    function TSelectIoHandler.getSockStream(clientSocket : longint) : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TSockStream.create(clientSocket));
    end;

    (*!-----------------------------------------------
     * called when client connection is allowed
     *-------------------------------------------------
     * @param clientSocket, socket handle where data can be read
     *-----------------------------------------------*)
    function TSelectIoHandler.handleClientConnection(clientSocket : longint) : boolean;
    var aStream : TCloseableStream;
    begin
        result := true;
        if (assigned(fDataAvailListener)) then
        begin
            aStream := TCloseableStream.create(
                clientSocket,
                getSockStream(clientSocket)
            );
            try
                result := fDataAvailListener.handleData(aStream, self, astream, astream);
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
    function TSelectIoHandler.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataAvailListener := dataListener;
        result := self;
    end;

    procedure TSelectIoHandler.shutdown();
    begin
        closeSocket(listenSocket);
        fDataAvailListener := nil;
    end;

    function TSelectIoHandler.run() : IRunnable;
    begin
        bind();
        listen();
        handleConnection();
        result := self;
    end;

end.
