{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit InetSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    SocketSvrImpl;

type

    (*!-----------------------------------------------
     * TCP hostname:port server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TInetSocketSvr = class(TSocketSvr)
    private
        fHost : string;
        fPort : word;
        FInetAddr : TInetSockAddr;
    protected
        (*!-----------------------------------------------
         * bind socket to an Inet socket address
         *-----------------------------------------------*)
        procedure bind(); override;

        (*!-----------------------------------------------
        * accept connection
        *-------------------------------------------------
        * @param listenSocket, socket handle created with fpSocket()
        * @return client socket which data can be read
        *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; override;

    public

        (*!-----------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param host, hostname or ip
         * @param port, port
         *-----------------------------------------------*)
        constructor create(const host : string; const port : word);

    end;

implementation

uses

    SysUtils,
    BaseUnix,
    Unix,
    ESockCreateImpl,
    ESockBindImpl;

resourcestring

    rsBindFailed = 'Bind failed on %s:%d, error: %d';
    rsCreateFailed = 'Create socket on %s:%d failed, error: %d';

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param host, hostname or ip
     * @param port, port
     *-----------------------------------------------*)
    constructor TInetSocketSvr.create(const host : string; const port : word);
    var socket : longint;
    begin
        fHost := host;
        fPort := port;
        socket := fpSocket(AF_INET, SOCK_STREAM, 0);
        if socket = -1 then
        begin
            raise ESockCreate.createFmt(rsCreateFailed,[ host, port, socketError() ]);
        end else
        begin
            inherited create(socket);
        end;
    end;


    (*!-----------------------------------------------
     * bind socket to an socket address
     s*-----------------------------------------------*)
    procedure TInetSocketSvr.bind();
    begin
        FInetAddr.sin_family := AF_INET;
        FInetAddr.sin_port := ShortHostToNet(FPort);
        FInetAddr.sin_addr.s_addr := LongWord(StrToNetAddr(FHost));
        if fpBind(fListenSocket, @FInetAddr, sizeof(FInetAddr)) <> 0 then
        begin
            raise ESockBind.createFmt(rsBindFailed, [ FHost, FPort, socketError() ]);
        end;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TInetSocketSvr.accept(listenSocket : longint) : longint;
    begin
        result := fpAccept(listenSocket, @FInetAddr, sizeof(FInetAddr));
    end;

end.
