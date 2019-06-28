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
     * @credit https://github.com/graemeg/freepascal/blob/master/packages/fcl-net/src/ssockets.pp
     *-----------------------------------------------*)
    TBoundSocketServer = class(TSocketServer)
    private
        fAccepting : boolean;
    protected
        procedure bind(); override;
        function accept(): longint; override;
        function getConnection() : TSocketStream; override;
    public
        procedure listen();
        procedure startAccepting();
        procedure stopAccepting(doAbort : boolean = false);
    end;

implementation

{$IFDEF UNIX}
uses
    baseunix;
{$ENDIF}

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

    function TBoundSocketServer.accept(): longint;
    var r : longint;
    begin
        {$IFDEF UNIX}
            r := ESysEINTR;
            while (r = ESysEINTR) do
            begin
                result := sockets.fpAccept(socket, nil, nil);
                r := SocketError;
            end;
        {$ELSE}
            result := sockets.fpAccept(socket, nil, nil);
            r := SocketError;
        {$ENDIF}

        {$IFDEF UNIX}
            if (result <0 ) then
            begin
                if r = ESysEWOULDBLOCK then
                begin
                    raise ESocketError.Create(seAcceptWouldBlock,[socket]);
                end;
            end;
        {$ENDIF}

        if (result < 0) or not fAccepting then
        begin
            if (result >= 0) then
            begin
                closeSocket(result);
            end;

            // Do not raise an error if we've stopped accepting.
            if fAccepting then
            begin
                raise ESocketError.Create(seAcceptFailed,[Socket,SocketError]);
            end;
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

        if fAccepting and DoConnectQuery(newSocket) then
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

    procedure TBoundSocketServer.startAccepting();
    begin
        fAccepting := true;
        inherited startAccepting();
    end;

    procedure TBoundSocketServer.stopAccepting(doAbort : boolean = false);
    begin
        inherited stopAccepting(doAbort);
        fAccepting := false;
    end;
end.
