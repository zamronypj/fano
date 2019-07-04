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
    protected
        procedure bind(); override;
        procedure shutdown(); override;
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
    ESockCreateImpl;

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


    procedure TUnixSocketSvr.bind();
    var
        addrLen  : longint;
        unixAddr : TUnixSockAddr;
    begin
        str2UnixSockAddr(fSocketFile, FUnixAddr, addrLen);
        if fpBind(fListenSocket, @UnixAddr, addrLen) <> 0 then
        begin
            raise ESockBind.createFmt(rsBindFailed, [ FSocketFile, socketError() ]);
        end;
        fSocketAddr : @UnixAddr;
        fSocketAddrLen := addrLen;
    end;

    procedure TUnixSocketSvr.shutdown();
    begin
        inherited shutdown();
        if (fileExists(fSocketFile)) then
        begin
            deleteFile(fSocketFile);
        end;
    end;

end.
