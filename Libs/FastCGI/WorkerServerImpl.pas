{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit WorkerServerImpl;

interface

{$MODE OBJFPC}
{$H+}


uses
    Classes,
    SysUtils,
    Sockets,
    SSockets,
    DataAvailListenerIntf,
    RunnableWithDataNotifIntf;

type

    (*!-----------------------------------------------
     * FastCGI web application worker server implementation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TWorkerServer = class(TInjectableObject, IRunnableWithDataNotif)
    private
        fHostName : string;
        fPort : word;
        server : TInetServer;
        fDataListener : IDataAvailListener;

        procedure DoConnect(Sender: TObject; Data: TSocketStream);
    public
        constructor create(const hostname: string; const port: word);
        destructor destroy(); override;

        (*!------------------------------------------------
        * set instance of class that will be notified when
        * data is available
        *-----------------------------------------------
        * @param dataListener, class that wish to be notified
        * @return true current instance
        *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    end;

implementation

    constructor TWorkerServer.create(const hostname: string; const port: word);
    begin
        fHostName := hostname;
        fPort := port;
        server := TInetServer.create(fHostName, fPort);
        server.OnConnect := @DoConnect;
        fDataListener := nil;
    end;

    destructor TWorkerServer.destroy();
    begin
        inherited destroy();
        FreeAndNil(server);
        fDataListener := nil;
    end;

    (*!------------------------------------------------
    * set instance of class that will be notified when
    * data is available
    *-----------------------------------------------
    * @param dataListener, class that wish to be notified
    * @return true current instance
    *-----------------------------------------------*)
    function TWorkerServer.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
    end;

    procedure TWorkerServer.DoConnect(Sender: TObject; Data: TSocketStream);
    begin
        if (assigned(fDataListener)) then
        begin
            fDataListener.handleData(TStreamAdapter.create(data), sender);
        end;
    end;

    function TWorkerServer.run() : IRunnable;
    begin
        server.startAccepting();
        result := self;
    end;
end.
