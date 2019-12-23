{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DaemonAppServiceProviderImpl;

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
    BasicAppServiceProviderImpl;

type

    {*------------------------------------------------
     * interface for any class having capability to
     * register one or more service factories
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TDaemonAppServiceProvider = class abstract (TBasicAppServiceProvider, IDaemonAppServiceProvider)
    protected
        fServer : IRunnableWithDataNotif;
        fProtocol : IProtocolProcessor;
        fOutputBuffer : IOutputBuffer;
        fStdOut : IStdOut;

        function buildStdIn(const ctnr : IDependencyContainer) : IStdIn; override;
    public
        constructor create();
        destructor destroy(); override;

        function getServer() : IRunnableWithDataNotif; virtual;

        function getProtocol() : IProtocolProcessor; virtual;

        function getOutputBuffer() : IOutputBuffer; virtual;

        function getStdOut() : IStdOut; virtual;

    end;

implementation

uses

    StdInFromStreamImpl,
    NullStreamAdapterImpl,
    NullStdOutImpl,
    NullProtocolProcessorImpl,
    NullRunnableWithDataNotifImpl,
    OutputBufferImpl;

    constructor TDaemonAppServiceProvider.create();
    begin
        inherited create();
        fServer := TNullRunnableWithDataNotif.create();
        fProtocol := TNullProtocolProcessor.create();
        fStdOut := TNullStdOut.create();
        fOutputBuffer := TOutputBuffer.create();
    end;

    destructor TDaemonAppServiceProvider.destroy();
    begin
        fServer := nil;
        fProtocol := nil;
        fStdOut := nil;
        fOutputBuffer := nil;
        inherited destroy();
    end;

    function TDaemonAppServiceProvider.buildStdIn(const ctnr : IDependencyContainer) : IStdIn;
    begin
        result := TStdInFromStream.create(TNullStreamAdapter.create());
    end;

    function TDaemonAppServiceProvider.getOutputBuffer() : IOutputBuffer;
    begin
        result := fOutputBuffer;
    end;

    function TDaemonAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        result := fServer;
    end;

    function TDaemonAppServiceProvider.getProtocol() : IProtocolProcessor;
    begin
        result := fProtocol;
    end;

    function TDaemonAppServiceProvider.getStdOut() : IStdOut;
    begin
        result := fStdOut;
    end;
end.
