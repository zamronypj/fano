{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MultiThreadDaemonAppServiceProviderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DaemonAppServiceProviderIntf,
    AppServiceProviderIntf,
    DependencyContainerIntf,
    ServiceProviderIntf,
    ErrorHandlerIntf,
    DispatcherIntf,
    EnvironmentIntf,
    StdInIntf,
    StdOutIntf,
    OutputBufferIntf,
    RouteMatcherIntf,
    RouterIntf,
    RunnableWithDataNotifIntf,
    ProtocolProcessorIntf,
    DataAvailListenerIntf,
    TaskQueueIntf,
    RunnableIntf,
    DecoratorDaemonAppServiceProviderImpl,
    WorkerThreadManagerImpl;

type

    {*------------------------------------------------
     * Service provider for multiple-thread daemon app
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TMultiThreadDaemonAppServiceProvider = class (
        TDecoratorDaemonAppServiceProvider,
        IDaemonAppServiceProvider,
        IRunnableWithDataNotif
    )
    private
        fWorkerThreadMgr : TWorkerThreadManager;
        fTaskQueue : ITaskQueue;
        fConnQueuer : IDataAvailListener;
    protected
        function buildTaskQueue() : ITaskQueue; virtual;
    public
        constructor create(
            const actualSvc : IDaemonAppServiceProvider;
            const numWorkerThread : integer
        );
        destructor destroy(); override;

        function getServer() : IRunnableWithDataNotif; override;

        (*!------------------------------------------------
        * set instance of class that will be notified when
        * data is available
        *-----------------------------------------------
        * @param dataListener, class that wish to be notified
        * @return true current instance
        *-----------------------------------------------*)
        function setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;

        (*!------------------------------------------------
         * run worker threads and server
         *-------------------------------------------------
         * @return current instance
         *-------------------------------------------------*)
        function run() : IRunnable;

    end;

implementation

uses

    StdInFromStreamImpl,
    NullStreamAdapterImpl,
    NullStdOutImpl,
    NullProtocolProcessorImpl,
    NullRunnableWithDataNotifImpl,
    OutputBufferImpl,
    StreamQueueImpl,
    TaskQueueImpl,
    ThreadSafeTaskQueueImpl;

    constructor TMultiThreadDaemonAppServiceProvider.create(
        const actualSvc : IDaemonAppServiceProvider;
        const numWorkerThread : integer
    );
    begin
        inherited create(actualSvc);
        fTaskQueue := buildTaskQueue();
        fWorkerThreadMgr := TWorkerThreadManager.create(fTaskQueue, numWorkerThread);
    end;

    destructor TMultiThreadDaemonAppServiceProvider.destroy();
    begin
        fWorkerThreadMgr.free();
        fTaskQueue := nil;
        inherited destroy();
    end;

    function TMultiThreadDaemonAppServiceProvider.buildTaskQueue() : ITaskQueue;
    begin
        result := TThreadSafeTaskQueue.create(TTaskQueue.create());
    end;

    function TMultiThreadDaemonAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        //we will act as the server. We will
        //delegate actual server work to fDaemon.server
        result := self;
    end;

    (*!------------------------------------------------
     * set instance of class that will be notified when
     * data is available
     *-----------------------------------------------
     * @param dataListener, class that wish to be notified
     * @return true current instance
     *-----------------------------------------------*)
    function TMultiThreadDaemonAppServiceProvider.setDataAvailListener(const dataListener : IDataAvailListener) : IRunnableWithDataNotif;
    begin
        //intentionally does nothing as we will handle data available on our own
        fConnQueuer := TStreamQueue.create(fTaskQueue, fDaemonSvc.protocol);
        fDaemonSvc.server.setDataAvailListener(fConnQueuer);
        result := self;
    end;

    (*!------------------------------------------------
     * run worker threads and server
     *-------------------------------------------------
     * @return current instance
     *-------------------------------------------------*)
    function TMultiThreadDaemonAppServiceProvider.run() : IRunnable;
    begin
        //start worker thread and server
        fWorkerThreadMgr.run();
        fDaemonSvc.server.run();
    end;

end.
