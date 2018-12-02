unit SocketAppImpl;

interface

{$MODE OBJFPC}

uses
    {$IFDEF UNIX}
    cthreads,
    {$ENDIF}
    classes,
    sysutils,
    sockets,
    fpAsync,
    fpSock,
    ThreadIntf,
    ThreadPoolIntf;

type

    TSocketWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        evLoop: TEventLoop;
        server : TTCPServer;
        threadPool : IThreadPool;
        procedure handleConnect(Sender: TConnectionBasedSocket; AStream: TSocketStream);
    public
        constructor create(const pool : IThreadPool; const port : integer);
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

type

    TSocketThread = class(TThread)
    private
       clientStream: TSocketStream;
    public
       constructor create(AClientStream: TSocketStream);
       procedure execute(); override;
    end;

    TSocketThreadPoolItem = class(TInterfacedObject, IThread)
    private
        actualThread : TSocketThread;
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * get current thread status
         *-------------------------------------------------
         * @return true is thread is idle, false if thread is
         * busy working
         *-------------------------------------------------*)
        function idle() : boolean;

        (*!------------------------------------------------
         * tell thread to start running
         *------------------------------------------------
         * If thread already running, multiple call does nothing
         *-------------------------------------------------*)
        procedure start();

    end;

    (*!----------------------------------------
     * constructor
     *-----------------------------------------
     * @param AClientStream socket stream to use
     *-----------------------------------------*)
    constructor TSocketThread.create(AClientStream: TSocketStream);
    begin
        //create a fire and forget thread instance
        inherited create(false);
        FreeOnTerminate := true;

        clientStream := AClientStream;
    end;

    (*!----------------------------------------
     * called when thread is running
     *-----------------------------------------*)
    procedure TSocketThread.execute();
    begin
    end;

    constructor TSocketWebApplication.create(const port : integer);
    begin
        randomize();
        evLoop := TEventLoop.create;
        server := TTCPServer.create(nil);
        server.EventLoop := evLoop;
        server.Port := port;
    end;

    destructor destroy();
    begin
        inherited destroy;
        evLoop.free();
        server.free();
    end;

    procedure TSocketWebApplication.handleConnect(Sender: TConnectionBasedSocket; AStream: TSocketStream);
    begin
        writeLn('Handle incoming connection..');
        TSocketThread.create(AStream);
    end;

    function TSocketWebApplication.run() : IRunnable;
    begin
        server.active := true;
        server.eventLoop.run();
    end.
end.
