{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DaemonAppImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RunnableIntf,
    CloseableIntf,
    DependencyContainerIntf,
    AppImpl,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    OutputBufferIntf,
    DataAvailListenerIntf,
    RunnableWithDataNotifIntf,
    StdOutIntf,
    ProtocolProcessorIntf,
    ReadyListenerIntf,
    StreamAdapterIntf;

type

    (*!-----------------------------------------------
     * Base web application that implements IWebApplication
     * which run as daemon
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDaemonWebApplication = class(TFanoWebApplication, IDataAvailListener, IReadyListener)
    private
        workerServer : IRunnableWithDataNotif;
        fProcessor : IProtocolProcessor;
        fOutputBuffer : IOutputBuffer;
        fStdOutWriter : IStdOut;

        (*!-----------------------------------------------
         * attach ourself as listener and run socket server
         *-----------------------------------------------
         * Note that run keeps run until application is terminated
         *-----------------------------------------------*)
        procedure attachListenerAndRunServer();
    protected
        procedure executeRequest(const env : ICGIEnvironment);
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param container dependency container
         * @param env CGI environment instance
         * @param errHandler error handler
         *----------------------------------------------
         * This is provided to simplify thing by providing
         * default service provider
         *-----------------------------------------------*)
        constructor create(
            const container : IDependencyContainer;
            const errHandler : IErrorHandler;
            const dispatcherInst : IDispatcher;
            const server : IRunnableWithDataNotif;
            const aProcessor : IProtocolProcessor;
            const outputBuffer : IOutputBuffer;
            const stdOutWriter : IStdOut
        );
        destructor destroy(); override;
        function run() : IRunnable; override;

        (*!------------------------------------------------
         * called when socket stream contains data
         *-----------------------------------------------
         * @param stream, stream of socket
         * @param context, sender i.e, TSocketServer instance
         * @param streamCloser, instance that can close stream if required
         * @return true if data is handled
         *-----------------------------------------------*)
        function handleData(
            const stream : IStreamAdapter;
            const context : TObject;
            const streamCloser : ICloseable
        ) : boolean;

        (*!------------------------------------------------
         * FastCGI request is ready
         *-----------------------------------------------
         * @param socketStream, original socket stream
         * @param env, CGI environment
         * @param stdInStream, stream contains POST-ed data
         * @return true request is handled
         *-----------------------------------------------*)
        function ready(
            const socketStream : IStreamAdapter;
            const env : ICGIEnvironment;
            const stdInStream : IStreamAdapter
        ) : boolean;
    end;

implementation

uses

    SysUtils,
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl,
    ESockBindImpl,
    ESockCreateImpl,
    ESockListenImpl;

resourcestring

    //TODO refactor as this is duplicate with AppImpl.pas
    sHttp404Message = 'Not Found';
    sHttp405Message = 'Method Not Allowed';

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param container dependency container
     * @param env CGI environment instance
     * @param errHandler error handler
     *----------------------------------------------
     * This is provided to simplify thing by providing
     * default service provider
     *-----------------------------------------------*)
    constructor TDaemonWebApplication.create(
        const container : IDependencyContainer;
        const errHandler : IErrorHandler;
        const dispatcherInst : IDispatcher;
        const server : IRunnableWithDataNotif;
        const aProcessor : IProtocolProcessor;
        const outputBuffer : IOutputBuffer;
        const stdOutWriter : IStdOut
    );
    begin
        inherited create(container, nil, errHandler);
        dispatcher := dispatcherInst;
        workerServer := server;
        fProcessor := aProcessor;
        fOutputBuffer := outputBuffer;
        fStdOutWriter := stdOutWriter;
    end;

    destructor TDaemonWebApplication.destroy();
    begin
        inherited destroy();
        dispatcher := nil;
        workerServer := nil;
        fProcessor := nil;
        fOutputBuffer := nil;
        fStdOutWriter := nil;
    end;

    (*!-----------------------------------------------
     * attach ourself as listener and run socket server
     *-----------------------------------------------
     * Note that run keeps run until application is terminated
     *-----------------------------------------------*)
    procedure TDaemonWebApplication.attachListenerAndRunServer();
    begin
        //This is to ensure that reference count of our instance
        //properly incremented/decremented so no memory leak
        fProcessor.setReadyListener(self);
        workerServer.setDataAvailListener(self);
        try
            try
                //execute run loop until terminated
                workerServer.run();
            except
                //TODO add better exception handling for ESockBind, ESockListen, ESockCreate
                on e : ESockCreate do
                begin
                    writeln(e.message);
                end;
                on e : ESockBind do
                begin
                    writeln(e.message);
                end;
                on e : ESockListen do
                begin
                    writeln(e.message);
                end;
            end;
        finally
            fProcessor.setReadyListener(nil);
            workerServer.setDataAvailListener(nil);
        end;
    end;

    (*!-----------------------------------------------
     * run application
     *------------------------------------------------
     * @return current instance.
     *-----------------------------------------------
     * Note that run keeps run until application is terminated
     *-----------------------------------------------*)
    function TDaemonWebApplication.run() : IRunnable;
    begin
        if (initialize(dependencyContainer)) then
        begin
            attachListenerAndRunServer();
        end;
        result := self;
    end;

    (*!-----------------------------------------------
     * execute request
     *------------------------------------------------
     * @param env, CGI environment
     *-----------------------------------------------*)
    procedure TDaemonWebApplication.executeRequest(const env : ICGIEnvironment);
    begin
        try
            environment := env;
            execute();
        except
              on e : ERouteHandlerNotFound do
              begin
                  errorHandler.handleError(e, 404, sHttp404Message);
              end;

              on e : EMethodNotAllowed do
              begin
                  errorHandler.handleError(e, 405, sHttp405Message);
              end;

              on e : Exception do
              begin
                  errorHandler.handleError(e);
              end;
        end;
    end;

    (*!-----------------------------------------------
     * called when socket contain data available to be
     * processed
     *------------------------------------------------
     * @param stream, socket stream
     * @param context, additional related data related,
     *        mostly contain sender (if any)
     * @param streamCloser, instance that can close stream if required
     * @return true if data is handled
     *-----------------------------------------------*)
    function TDaemonWebApplication.handleData(
        const stream : IStreamAdapter;
        const context : TObject;
        const streamCloser : ICloseable
    ) : boolean;
    begin
        fProcessor.process(stream, streamCloser);
        result := true;
    end;

    (*!------------------------------------------------
     * Request is ready
     *-----------------------------------------------
     * @param socketStream, original socket stream
     * @param env, CGI environment
     * @param stdInStream, stream contains POST-ed data
     * @return true request is handled
     *-----------------------------------------------*)
    function TDaemonWebApplication.ready(
        const socketStream : IStreamAdapter;
        const env : ICGIEnvironment;
        const stdInStream : IStreamAdapter
    ) : boolean;
    begin
        //buffer STDOUT, so any write()/writeln() will be buffered to stream
        fOutputBuffer.beginBuffering();
        try
            //when we get here, CGI environment and any POST data are ready
            executeRequest(env);
        finally
            fOutputBuffer.endBuffering();
            //write response back to web server (i.e FastCGI client)
            fStdOutWriter.setStream(socketStream).write(fOutputBuffer.flush());
        end;
        result := true;
    end;
end.
