{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BoundSocketServerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sockets,
    ssockets;

type


    (*!-----------------------------------------------
     * Socket server that use already bound socket instead of
     * bind and listen on its own
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBoundSocketServer = class(TSocketServer)
    protected
        procedure bind(); override;
        function accept(): longint; override;
        function getConnection() : TSocketStream; override;
    public
        procedure listen();
    end;

implementation

resourcestring

    strSocketAcceptFailed = 'Could not accept a client connection on socket: %d, error %d';
    strSocketAcceptWouldBlock = 'Accept would block on socket: %d';

    procedure TBoundSocketServer.bind();
    begin
        //socket is assumed already bound and listening, so do nothing here
        //only mark status as bound
        fBound := true;
    end;

    function TBoundSocketServer.accept(): longint;
    begin
        result := sockets.fpAccept(socket, nil, nil);
        If result < 0 then
        begin
            if SocketError = ESysEWOULDBLOCK then
            begin
                raise ESocketError.Create(seAcceptWouldBlock,[socket]);
            end else
            begin
                raise ESocketError.Create(seAcceptFailed,[ socket, socketError ]);
            end
        end;
    end;

    procedure TBoundSocketServer.listen();
    begin
        //socket is assumed already bound and listening, so do nothing here
    end;

    function TBoundSocketServer.getConnection() : TSocketStream;
    var newSocket : longint;
    begin
        result := nil;
        newSocket := accept();
        if (newSocket < 0) then
        begin
            raise ESocketError.Create(seAcceptFailed,[Socket,SocketError]);
        end;

        if FAccepting and DoConnectQuery(newSocket) then
        begin
            result := SockToStream(newSocket);
        end else
        begin
            closeSocket(newSocket);
        end;
    end;

    function TBoundSocketServer.SockToStream(aSocket : longint) : TSocketStream;
    begin
        result := TSocketStream.create(aSocket);
    end;
end.
