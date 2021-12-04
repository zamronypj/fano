{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit LnetServiceProviderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SyncObjs,
    RunnableWithDataNotifIntf,
    DaemonAppServiceProviderIntf,
    RequestResponseFactoryIntf,
    ProtocolAppServiceProviderImpl,
    HttpSvrConfigTypes;

type

    {*------------------------------------------------
     * class having capability to
     * register one or more service factories that use
     * LNet TLHTTPServer
     * https://github.com/almindor/lnet
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TLnetAppServiceProvider = class (TProtocolAppServiceProvider)
    private
        fLock : TCriticalSection;
        fServer : IRunnableWithDataNotif;
    public
        constructor create(
            const actualSvc : IDaemonAppServiceProvider;
            const svrConfig : THttpSvrConfig
        );
        destructor destroy(); override;
        function getServer() : IRunnableWithDataNotif; override;
    end;

implementation

uses

    StdOutIntf,
    ProtocolProcessorIntf,
    RunnableIntf,
    LnetProcessorImpl,
    LnetStdOutWriterImpl,
    ThreadSafeFpwebResponseAwareImpl,
    FpwebResponseAwareIntf;

    constructor TLnetAppServiceProvider.create(
        const actualSvc : IDaemonAppServiceProvider;
        const svrConfig : TFpwebSvrConfig
    );
    begin
        inherited create(actualSvc);
        fLock := TCriticalSection.create();

        fStdOut := TLnetStdOutWriter.create();

        fProtocol := TLnetProcessor.create(
            fLock,
            fStdOut as ILnetResponseAware,
            svrConfig
        );

        //TLnetProcessor also act as server
        fServer := fProtocol as IRunnableWithDataNotif;
    end;

    destructor TLnetAppServiceProvider.destroy();
    begin
        fServer := nil;
        fStdOut := nil;
        fProtocol := nil;
        fLock.free();
        inherited destroy();
    end;

    function TLnetAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        result := fServer;
    end;

end.
