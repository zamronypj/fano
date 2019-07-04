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
    protected
        procedure bind(); override;
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
    ESockCreateImpl;

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


    procedure TInetSocketSvr.bind();
    var
        addrLen  : longint;
        inetAddr : TInetSockAddr;
    begin
        inetAddr.sin_family := AF_INET;
        inetAddr.sin_port := ShortHostToNet(FPort);
        inetAddr.sin_addr.s_addr := LongWord(StrToNetAddr(FHost));
        addrLen := sizeof(inetAddr);
        if fpBind(fListenSocket, @inetAddr, addrLen) <> 0 then
        begin
            raise ESockBind.createFmt(rsBindFailed, [ FHost, FPort, socketError() ]);
        end;
        fSocketAddr := @inetAddr;
        fSocketAddrLen := addrLen;
    end;
end.
