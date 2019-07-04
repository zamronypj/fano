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
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSocketSvr = class(TInterfacedObject, IRunnable, IRunnableWithDataNotif)
    private

        (*!-----------------------------------------------
         * called when client connection is established
         *-------------------------------------------------
         * @param clientSocket, socket handle where data can be read
         *-----------------------------------------------*)
        procedure doConnect(clientSocket : longint);

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
        procedure listen();

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
         * get stream fron socket
         *-------------------------------------------------
         * @param clientSocket, socket handle
         * @return stream of socket
         *-----------------------------------------------*)
        function getSockStream(clientSocket : longint) : IStreamAdapter; virtual; abstract;
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
        function run() : IRunnable;

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

    BaseUnix,
    Unix,
    ESockListenImpl;

resourcestring

    rsSocketListenFailed = 'Listening failed, error: %d';

var

    //pipe handle that we use to monitor if we get SIGTERM/SIGINT signal
    terminatePipeIn, terminatePipeOut : longInt;

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
     * handle incoming connection until terminated
     *-----------------------------------------------*)
    procedure TSocketSvr.handleConnection();
    var readfds : TFDSet;
        maxHandle : longint;
        terminated : boolean;
        clientSocket : longint;
        ch : char;
    begin
        repeat

            //initialize struct and reset all file descriptors
            readfds := default(TFDSet);
            fpFD_ZERO(readfds);

            //add fListenSocket to set of read file descriptor we need to monitor
            //so we know if there something happen with listening socket
            fpFD_SET(fListenSocket, readfds);

            //also add terminatePipeIn so we get notified if we get signal to terminate
            fpFD_SET(terminatePipeIn, fds);

            //find file descriptor with biggest value
            maxHandle := 0;
            if (fListenSocket > maxHandle) then
            begin
                maxHandle := fListenSocket;
            end;

            if (terminatePipeIn > maxHandle) then
            begin
                maxHandle := terminatePipeIn;
            end;

            //wait indefinitely until something happen in fListenSocket or terminatePipeIn
            if fpSelect(maxHandle + 1, @fds, nil, nil, nil) > 0 then
            begin
                //we have something, check further
                if fpFD_ISSET(terminatePipeIn, fds) > 0 then
                begin
                    //we get termination signal, just read until no more
                    //bytes and quit
                    fpRead(terminatePipeIn, @ch, 1);
                    terminated := true;
                end else
                if fpFD_ISSET(fListenSocket, fds) > 0 then
                begin
                    //we have something with listening socket. It means there is
                    //new connection coming, accept it
                    clientSocket := accept(fListenSocket);

                    //ask if we allow this connection
                    if doCanConnect(clientSocket) then
                    begin
                        //allow this connection, tell that data is available
                        doConnect(clientSocket);
                    end;
                end;
            end;
        until terminated;
    end;

    (*!-----------------------------------------------
     * called when client connection is allowed
     *-------------------------------------------------
     * @param clientSocket, socket handle where data can be read
     *-----------------------------------------------*)
    procedure TSocketSvr.doConnect(clientSocket : longint);
    begin
        if (assigned(fDataAvailListener)) then
        begin
            fDataAvailListener.handleData(getSockStream(clientSocket), nil, nil);
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
    procedure doTerminate(sig : longint; info : PSigInfo; ctx : PSigContext); cdecl;
    begin
        //write one byte to mark termination
        write(terminatePipeOut, '.');
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

    close(terminatePipeIn);
    close(terminatePipeOut);

end.
