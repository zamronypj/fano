{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractSocketImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    SocketIntf,
    ListenSocketIntf;

type

    (*!------------------------------------------------
     * abstract class having capability setup listen socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractSocket = class abstract (TInterfacedObject, IListenSocket)
    private
        fSocket : longint;
        procedure raiseExceptIfFailed(const socket : longint; const msg : string);
    protected
        function createSocket() : longint; virtual; abstract;
    public

        (*!-----------------------------------------------
         * return listen socket
         *-----------------------------------------------*)
        function getSocket() : longint;

        (*!-----------------------------------------------
         * return textual information regarding socket
         *-----------------------------------------------*)
        function getInfo() : string; virtual; abstract;

        (*!-----------------------------------------------
         * bind socket to an socket address
         *-----------------------------------------------*)
        procedure bind(); virtual; abstract;

        (*!-----------------------------------------------
        * accept connection
        *-------------------------------------------------
        * @param listenSocket, socket handle
        * @return client socket which data can be read
        *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; virtual; abstract;

        (*!-----------------------------------------------
         * start listen for incoming connection
         *-----------------------------------------------*)
        procedure listen(); virtual;
    end;

implementation

uses

    SocketConsts,
    ESockCreateImpl;

    procedure TAbstractSocket.raiseExceptIfFailed(const socket : longint; const msg : string);
    var errCode : longint;
    begin
        if socket = -1 then
        begin
            errCode := socketError();
            raise ESockCreate.createFmt(
                rsCreateFailed,
                [ msg, strError(errCode), errCode ]
            );
        end;
    end;

    (*!-----------------------------------------------
     * constructor
     *-----------------------------------------------*)
    constructor TAbstractSocket.create();
    begin
        fSocket := createSocket();
        raiseExceptIfFailed(fSocket, getInfo());
    end;

    (*!-----------------------------------------------
     * create socket and return listen socket
     *-----------------------------------------------*)
    function TAbstractSocket.getSocket() : longint;
    begin
        result := fSocket;
    end;

    (*!-----------------------------------------------
     * start listen for incoming connection
     *-----------------------------------------------*)
    procedure TAbstractSocket.listen();
    var errCode : longint;
    begin
        if fpListen(fSocket, fQueueSize) <> 0 then
        begin
            errCode := socketError();
            raise ESockListen.createFmt(
                rsSocketListenFailed,
                errCode,
                strError(errCode)
            );
        end;
    end;
end.
