{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit BaseWorkerServerImpl;

interface

{$MODE OBJFPC}
{$H+}


uses
    Classes,
    SysUtils,
    Sockets,
    SSockets,
    InjectableObjectImpl,
    DataAvailListenerIntf,
    RunnableIntf,
    RunnableWithDataNotifIntf;

type

    (*!-----------------------------------------------
     * Base FastCGI web application worker server implementation
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBaseWorkerServer = class(TInjectableObject, IRunnableWithDataNotif)
    protected
        fDataListener : IDataAvailListener;
        fServer : TSocketServer;

        procedure DoConnect(Sender: TObject; Data: TSocketStream);
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
        * set instance of class that will be notified when
        * data is available
        *-----------------------------------------------
        * @param dataListener, class that wish to be notified
        * @return true current instance
        *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;

        function run() : IRunnable;
    end;

implementation

uses

    StreamAdapterImpl;

    constructor TBaseWorkerServer.create();
    begin
        fDataListener := nil;
        fServer := nil;
    end;

    destructor TBaseWorkerServer.destroy();
    begin
        inherited destroy();
        freeAndNil(fServer);
        fDataListener := nil;
    end;

    (*!------------------------------------------------
    * set instance of class that will be notified when
    * data is available
    *-----------------------------------------------
    * @param dataListener, class that wish to be notified
    * @return true current instance
    *-----------------------------------------------*)
    function TBaseWorkerServer.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        fDataListener := dataListener;
    end;

    procedure TBaseWorkerServer.DoConnect(Sender: TObject; Data: TSocketStream);
    begin
        if (assigned(fDataListener)) then
        begin
            fDataListener.handleData(TStreamAdapter.create(data), sender);
        end;
    end;

    function TBaseWorkerServer.run() : IRunnable;
    begin
        fServer.startAccepting();
        result := self;
    end;
end.
