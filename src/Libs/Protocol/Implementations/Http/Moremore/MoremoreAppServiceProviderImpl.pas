{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MoremoreAppServiceProviderImpl;

interface

{$MODE DELPHI}
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
     * TFPHttpServer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TMoremoreAppServiceProvider = class (TProtocolAppServiceProvider)
    private
        fLock: TCriticalSection;
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

    ProtocolProcessorIntf,
    StdOutIntf,
    RunnableIntf,
    MoremoreResponseAwareIntf,
    MoremoreProcessorImpl,
    MoremoreStdOutWriterImpl,
    ThreadSafeMoremoreResponseAwareImpl;

    constructor TMoremoreAppServiceProvider.create(
        const actualSvc : IDaemonAppServiceProvider;
        const svrConfig : THttpSvrConfig
    );
    var astdout : IStdOut;
    begin
        inherited create(actualSvc);
        fLock := TCriticalSection.create();

        aStdOut := TMoremoreStdOutWriter.create();
        fStdOut := TThreadSafeMoremoreResponseAware.create(
            fLock,
            aStdOut,
            aStdOut as IMoremoreResponseAware
        );

        fProtocol := TMoremoreProcessor.create(
            fLock,
            svrConfig,
            fStdOut  as IMoremoreResponseAware
        );

        //TMoremoreProcessor also act as server
        fServer := fProtocol as IRunnableWithDataNotif;
    end;

    destructor TMoremoreAppServiceProvider.destroy();
    begin
        fServer := nil;
        fProtocol := nil;
        fLock.free();
        inherited destroy();
    end;

    function TMoremoreAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        result := fServer;
    end;

end.
