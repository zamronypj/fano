{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EpollInetSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    EpollSocketSvrImpl;

type

    (*!-----------------------------------------------
     * TCP hostname:port server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     * This class using Linux epoll API to monitor file descriptors
     *---------------------------------------------------
     * TODO: refactor as this mostly same as TInetSocketSvr only different
     * ancestor
     *---------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollInetSocketSvr = class(TEpollSocketSvr)
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
    ESockBindImpl,
    SocketConsts;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param host, hostname or ip
     * @param port, port
     *-----------------------------------------------*)
    constructor TEpollInetSocketSvr.create(const host : string; const port : word);
    var socket, errCode : longint;
    begin
        fHost := host;
        fPort := port;
        socket := fpSocket(AF_INET, SOCK_STREAM, 0);
        if socket = -1 then
        begin
            errCode := socketError();
            raise ESockCreate.createFmt(
                rsCreateFailed,
                [ format('%s:%d', [host, port]), strError(errCode), errCode ]
            );
        end else
        begin
            inherited create(socket);
        end;
    end;

    (*!-----------------------------------------------
     * bind socket to an socket address
     * TODO: refactor as it is similar to TInetSocketSvr.bind()
     *-----------------------------------------------*)
    procedure TEpollInetSocketSvr.bind();
    var errCode : longint;
    begin
        FInetAddr.sin_family := AF_INET;
        FInetAddr.sin_port := htons(FPort);
        FInetAddr.sin_addr.s_addr := LongWord(StrToNetAddr(FHost));
        if fpBind(fListenSocket, @FInetAddr, sizeof(FInetAddr)) <> 0 then
        begin
            errCode := socketError();
            raise ESockBind.createFmt(
                rsBindFailed,
                [ format('%s:%d', [FHost, FPort]), strError(errCode), errCode ]
            );
        end;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TEpollInetSocketSvr.accept(listenSocket : longint) : longint;
    var addrLen : TSockLen;
    begin
        addrLen := sizeof(FInetAddr);
        result := fpAccept(listenSocket, @FInetAddr, @addrLen);
    end;

end.
