{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiAppImpl;

interface

uses

    fastcgi,
    AppIntf;

type

    TFcgiWebApplication = class(TInterfacedObject, IWebApplication)
    private
        actualApp : IWebApplication;
        serverHost : string;
        serverPort : integer;
        useUnixSocket : boolean;
        serverSocketFile : string;


        (*!-----------------------------------------------
         * execute application and write response
         *------------------------------------------------
         * @return current application instance
         *-----------------------------------------------
         * TODO: need to think about how to execute when
         * application is run as daemon.
         *-----------------------------------------------*)
        function acceptConnection() : IRunnable;

        (*!-----------------------------------------------
         * open socket
         *------------------------------------------------
         * @return current application instance
         *-----------------------------------------------
         * TODO: need to think about how to execute when
         * application is run as daemon.
         *-----------------------------------------------*)
        function openSocket() : IRunnable;
    public
        constructor create(
            const appInst : IWebApplication;
            const port : integer
        );
        destructor destroy; override;
        function run() : IRunnable;
    end;

implementation

uses

    ssockets;

    constructor TFcgiWebApplication.create(
        const appInst : IWebApplication;
        const port : integer
    );
    begin
        randomize();
        actualApp := appInst;
        serverPort := port;
    end;

    destructor TFcgiWebApplication.destroy();
    begin
        inherited destroy();
        actualApp := nil;
    end;

    function TFcgiWebApplication.processRecord(const fcgiRec : PFCGI_Header) : IRunnable;
    var requestId : word;
    begin
        env := readFastCGItoEnv(fcgiRec)
        dispatcher.dispatchRequest(env);
    end;

    procedure TFcgiWebApplication.onConnect(const sender : TObject; const stream : TSocketStream);
    var fcgiRec  : PFCGI_Header;
        serverSocket : TSocketServer;
        status : boolean;
    begin
        serverSocket := TSocketServer(sender);

        fcgiRec := readFCGIRecord(stream);
        // If connection closed gracefully, we have nil.
        if (not assigned(fcgiRec) then
        begin
            serverSocket.abort();
            serverSocket.close();
        end else
        begin
            try
                processRecord(fcgiRec);
            finally
                freeMem(fcgiRec);
            end;
        end;
    end;

    function TFcgiWebApplication.run() : IRunnable;
    var socketServer : TSocketServer;
    begin
        if (useUnixSocket) then
        begin
            socketServer := TUnixServer.create(serverSocketFile);
        end else
        begin
            socketServer := TInetSocket.create(serverHost, serverPort);
        end;
        try
            socketServer.onConnect := @onConnect;
            socketServer.startAccepting();
        finally
            socketServer.free();
        end;
    end;

end.
