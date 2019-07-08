{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UnixSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    SocketSvrImpl;

type

    (*!-----------------------------------------------
     * Unix domain socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUnixSocketSvr = class(TSocketSvr)
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
    ESockCreateImpl,
    ESockBindImpl;

resourcestring

    rsBindFailed = 'Bind failed on file %s, error: %d';
    rsCreateFailed = 'Create Socket on file %s failed, error: %d';

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @param queueSize, number of queue when listen, 5 = default of Berkeley Socket
     *-----------------------------------------------*)
    constructor TUnixSocketSvr.create(const filename : string);
    var socket : longint;
    begin
        fSocketFile := filename;
        socket := fpSocket(AF_UNIX, SOCK_STREAM, 0);
        if socket = -1 then
        begin
            raise ESockCreate.createFmt(rsCreateFailed,[ fileName, socketError() ]);
        end else
        begin
            inherited create(socket);
        end;
    end;

    (*!-----------------------------------------------
     * bind socket to an Inet socket address
     *-----------------------------------------------*)
    procedure TUnixSocketSvr.bind();
    var
        addrLen  : longint;
    begin
        str2UnixSockAddr(fSocketFile, FUnixAddr, addrLen);
        if fpBind(fListenSocket, @FUnixAddr, addrLen) <> 0 then
        begin
            raise ESockBind.createFmt(rsBindFailed, [ FSocketFile, socketError() ]);
        end;
        fSocketAddrLen := addrLen;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TUnixSocketSvr.accept(listenSocket : longint) : longint;
    var addrLen : TSockLen;
    begin
        addrLen := fSocketAddrLen;
        result := fpAccept(listenSocket, @FUnixAddr, @addrLen);
        fSocketAddrLen := addrLen;
    end;

    (*!-----------------------------------------------
     * run shutdown sequence
     *-----------------------------------------------*)
    procedure TUnixSocketSvr.shutdown();
    begin
        inherited shutdown();
        if (fileExists(fSocketFile)) then
        begin
            deleteFile(fSocketFile);
        end;
    end;
end.
