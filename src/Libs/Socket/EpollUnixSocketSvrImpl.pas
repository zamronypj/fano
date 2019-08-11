{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EpollUnixSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    EpollSocketSvrImpl;

type

    (*!-----------------------------------------------
     * Unix domain socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     * This class using Linux epoll API to monitor file descriptors
     *---------------------------------------------------
     * TODO: refactor as this mostly same as TUnixSocketSvr only different
     * ancestor
     *---------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollUnixSocketSvr = class(TEpollSocketSvr)
    private
        fSocketFile : string;
        FUnixAddr : TUnixSockAddr;
        fSocketAddrLen : TSockLen;
    protected
        (*!-----------------------------------------------
         * bind socket to an Unix socket address
         *-----------------------------------------------*)
        procedure bind(); override;

        (*!-----------------------------------------------
         * run shutdown sequence
         *-----------------------------------------------*)
        procedure shutdown(); override;

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
         * @param filename, filename of socket file
         *-----------------------------------------------*)
        constructor create(const filename : string);

    end;

implementation

uses

    SysUtils,
    BaseUnix,
    Unix,
    Errors,
    ESockCreateImpl,
    ESockBindImpl,
    SocketConsts;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
     * TODO: refactor as it is similar to TUnixSocketSvr.create()
     *-----------------------------------------------*)
    constructor TEpollUnixSocketSvr.create(const filename : string);
    var socket, errCode : longint;
    begin
        fSocketFile := filename;
        socket := fpSocket(AF_UNIX, SOCK_STREAM, 0);
        if socket = -1 then
        begin
            errCode := socketError();
            raise ESockCreate.createFmt(
                rsCreateUnixSockFailed,
                [ fileName, strError(errCode), errCode ]
            );
        end else
        begin
            inherited create(socket);
        end;
    end;

    (*!-----------------------------------------------
     * replacement for str2UnixSockAddr() which marked
     * as deprecated
     *-----------------------------------------------*)
    procedure StrToUnixAddr(const addr : string; var sockAddr : TUnixSockAddr; var len:longint);
    begin
        move(addr[1], sockAddr.Path, length(addr));
        sockAddr.Family := AF_UNIX;
        sockAddr.Path[length(addr)] := #0;
        len := length(addr) + 3;
    end;

    (*!-----------------------------------------------
     * bind socket to an Inet socket address
     * TODO: refactor as it is similar to TUnixSocketSvr.bind()
     *-----------------------------------------------*)
    procedure TEpollUnixSocketSvr.bind();
    var errCode : longint;
        addrLen  : longint;
    begin
        StrToUnixAddr(fSocketFile, FUnixAddr, addrLen);
        if fpBind(fListenSocket, @FUnixAddr, addrLen) <> 0 then
        begin
            errCode := socketError();
            raise ESockBind.createFmt(
                rsBindFailed,
                [ FSocketFile, strError(errCode), errCode ]
            );
        end;
        fSocketAddrLen := addrLen;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     * TODO: refactor as it is similar to TUnixSocketSvr.accept()
     *-----------------------------------------------*)
    function TEpollUnixSocketSvr.accept(listenSocket : longint) : longint;
    var addrLen : TSockLen;
    begin
        addrLen := fSocketAddrLen;
        result := fpAccept(listenSocket, @FUnixAddr, @addrLen);
        fSocketAddrLen := addrLen;
    end;

    (*!-----------------------------------------------
     * run shutdown sequence
     *-----------------------------------------------*)
    procedure TEpollUnixSocketSvr.shutdown();
    begin
        inherited shutdown();
        if (fileExists(fSocketFile)) then
        begin
            deleteFile(fSocketFile);
        end;
    end;
end.
