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

    Sockets;

type

    (*!-----------------------------------------------
     * Socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSocketSvr = class
    protected
        fSocketAddr : PSockAddr;
        fSocketAddrLen : PSockLen;

        fListenSocket : longint;
        fQueueSize : longint;

        procedure bind(); virtual; abstract;
        procedure listen();
        procedure runLoop();

        (*!-----------------------------------------------
         * accept connection
         *-------------------------------------------------
         * @param listenSocket, socket handle created with fpSocket()
         * @return client socket which data can be read
         *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint;

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

        procedure run();

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

    constructor TSocketSvr.create(
        listenSocket : longint;
        queueSize : integer = 5
    );
    begin
        fListenSocket := listenSocket;
        fQueueSize := queueSize;
    end;

    destructor TSocketSvr.destroy();
    begin
        closeSocket(fListenSocket);
        inherited destroy();
    end;


    procedure TSocketSvr.listen();
    begin
        if fpListen(fListenSocket, fQueueSize) <> 0 then
        begin
            raise ESockListen.createFmt(rsSocketListenFailed, [ socketError() ]);
        end;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TSocketSvr.accept(listenSocket : longint) : longint;
    begin
        result := fpAccept(listenSocket, @fSocketAddr, fSocketAddrLen);
    end;

    procedure TSocketSvr.runLoop();
    var readfds : TFDSet;
        maxHandle : longint;
        terminated : boolean;
        clientSocket : longint;
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
                if fpFD_ISSET(fListenSocket, fds) > 0 then
                begin
                    //we have something with listening socket. It means there is
                    //new connection coming, accept it
                    clientSocket := accept(fListenSocket);
                    //create stream from client socket and notify event handler for
                    //data availability

                end;
            end;

        until terminated;
    end;

    procedure TSocketSvr.run();
    begin
        bind();
        listen();
        fAccepting := true;
        runLoop();
        shutdown();
    end;

    procedure doTerminate(sig : longint; info : PSigInfo; ctx : PSigContext); cdecl;
    begin
        //write one byte to mark termination
        write(terminatePipeOut, '.');
    end;

    procedure installTerminateSignalHandler(aSig : longint);
    var oldAct, newAct : SigactionRec;
    begin
        fillChar(newAct, sizeOf(SigactionRec), #0);
        fillChar(oldAct, sizeOf(Sigactionrec), #0);
        newAct.sa_handler := @doShutDown;
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
