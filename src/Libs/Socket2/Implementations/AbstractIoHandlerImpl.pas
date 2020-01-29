{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractIoHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    IoHandlerIntf,
    DataAvailListenerIntf,
    StreamAdapterIntf,
    SocketOptsIntf,
    BaseUnix,
    Unix;

type

    (*!-----------------------------------------------
     * Base I/O handler implementation
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractIoHandler = class abstract (TInterfacedObject, IIoHandler)
    protected
        fSockOpts : ISocketOpts;
        fDataAvailListener : IDataAvailListener;

        procedure raiseExceptionIfAny();

        (*!-----------------------------------------------
         * get stream from socket
         *-------------------------------------------------
         * @param clientSocket, socket handle
         * @return stream of socket
         *-----------------------------------------------*)
        function getSockStream(clientSocket : longint) : IStreamAdapter; virtual;

    public
        constructor create(const sockOpts : ISocketOpts);
        destructor destroy(); override;

        (*!-----------------------------------------------
         * handle incoming connection until terminated
         *-----------------------------------------------*)
        procedure handleConnection(listenSocket : longint; termPipeIn : longint); virtual; abstract;

        (*!------------------------------------------------
         * set instance of class that will be notified when
         * data is available
         *-----------------------------------------------
         * @param dataListener, class that wish to be notified
         * @return true current instance
         *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IIoHandler;
    end;

implementation

uses

    SysUtils,
    Errors,
    SocketConsts,
    ESockWouldBlockImpl,
    ESockErrorImpl,
    StreamAdapterImpl,
    SockStreamImpl,
    DateUtils;

    constructor TAbstractIoHandler.create(const sockOpts : ISocketOpts);
    begin
        fSockOpts := sockOpts;
        fDataAvailListener := nil;
    end;

    destructor TAbstractIoHandler.destroy();
    begin
        fDataAvailListener := nil;
        fSockOpts := nil;
        inherited destroy();
    end;


    procedure TAbstractIoHandler.raiseExceptionIfAny();
    var errCode : longint;
    begin
        errCode := socketError();
        if (errCode = ESysEWOULDBLOCK) or (errCode = ESysEAGAIN) then
        begin
            //if we get here, it mostly because socket is non blocking
            //but no pending connection, so just do nothing
        end else
        begin
            raise ESockError.createFmt(
                rsSocketError,
                errCode,
                strError(errCode)
            );
        end;
    end;

    (*!-----------------------------------------------
     * get stream from socket
     *-------------------------------------------------
     * @param clientSocket, socket handle
     * @return stream of socket
     *-----------------------------------------------*)
    function TAbstractIoHandler.getSockStream(clientSocket : longint) : IStreamAdapter;
    begin
        result := TStreamAdapter.create(TSockStream.create(clientSocket));
    end;

    (*!------------------------------------------------
     * set instance of class that will be notified when
     * data is available
     *-----------------------------------------------
     * @param dataListener, class that wish to be notified
     * @return true current instance
    *-----------------------------------------------*)
    function TAbstractIoHandler.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataAvailListener := dataListener;
        result := self;
    end;
end.
