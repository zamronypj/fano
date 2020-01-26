{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit Socket2SvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RunnableIntf,
    ListenSocketIntf,
    IoHandlerIntf;

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
    TSocket2Svr = class (TInterfacedObject, IRunnable)
    private
        fSocket : IListenSocket;
        fIoHandler : IIoHandler;
    public
        constructor create(const socket : IListenSocket; const ioHandler : IIoHandler);
        destructor destroy(); override;

        (*!-----------------------------------------------
         * run socket server until terminated
         *-----------------------------------------------*)
        function run() : IRunnable;
    end;

implementation

uses

    TermSignalImpl;

    constructor TSocket2Svr.create(
        const socket : IListenSocket;
        const ioHandler : IIoHandler
    );
    begin
        fSocket := socket;
        fIoHandler := ioHandler;
    end;

    destructor TSocket2Svr.destroy();
    begin
        fSocket := nil;
        fIoHandler := nil;
        inherited destroy();
    end;

    function TSocket2Svr.run() : IRunnable;
    begin
        fSocket.bind();
        fSocket.listen();
        fIoHandler.handleConnection(fSocket.getSocket(), terminatePipeIn);
        result := self;
    end;

end.
