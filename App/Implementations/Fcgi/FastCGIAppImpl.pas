{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FastCGIAppImpl;

interface

{$MODE OBJFPC}
{$H+}


uses

    RunnableIntf,
    DependencyContainerIntf,
    AppImpl,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    OutputBufferIntf,
    DataAvailListenerIntf,
    RunnableWithDataNotifIntf,
    FcgiProcessorIntf;

type

    (*!-----------------------------------------------
     * FastCGI web application that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFastCGIWebApplication = class(TFanoWebApplication, IDataAvailListener)
    private
        workerServer : RunnableWithDataNotifIntf;
        fcgiProcessor : IFcgiFrameParser;
        fOutputBuffer : IOutputBuffer;
    protected
        function initialize(const container : IDependencyContainer) : boolean; override;

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
            const aFcgiProcessor : IFcgiProcessor;
            const outputBuffer : IOutputBuffer
        );
        destructor destroy(); override;
        function run() : IRunnable;

        function handleData(const stream : IStreamAdapter; const context : TObject) : boolean;
    end;

implementation

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
    constructor TFastCGIWebApplication.create(
        const container : IDependencyContainer;
        const errHandler : IErrorHandler;
        const dispatcherInst : IDispatcher;
        const server : IRunnableWithDataNotif;
        const aFcgiProcessor : IFcgiProcessor
    );
    begin
        inherited create(container, nil, errHandler);
        dispatcher := dispatcherInst;
        workerServer := server;
        fcgiProcessor := aFcgiProcessor;
        fOutputBuffer := outputBuffer;
    end;

    destructor TFastCGIWebApplication.destroy();
    begin
        inherited destroy();
        workerServer := nil;
        fcgiProcessor := nil;
        fOutputBuffer := nil;
    end;

    (*!-----------------------------------------------
     * initialize application dependencies
     *------------------------------------------------
     * @param container dependency container
     * @return true if application dependency succesfully
     * constructed
     *-----------------------------------------------
     * TODO: need to think about how to initialize when
     * application is run as daemon. Current implementation
     * is we put this in run() method which maybe not right
     * place.
     *-----------------------------------------------*)
    function TFastCGIWebApplication.initialize(const container : IDependencyContainer) : boolean;
    begin
        inherited initialize(container);
        workerServer.setDataAvailListener(self);
        result := true;
    end;

    function TFastCGIWebApplication.run() : IRunnable;
    begin
        if (initialize(dependencyContainer)) then
        begin
            workerServer.run();
        end;
        result := self;
    end;

    procedure TFastCGIWebApplication.executeRequest(const env : ICGIEnvironment);
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

    function TFastCGIWebApplication.handleData(const stream : IStreamAdapter; const context : TObject) : boolean;
    begin
        if (fcgiProcessor.process(stream)) then
        begin
            fOutputBuffer.beginBuffering();
            try
                executeRequest(fcgiProcessor.getEnvironment());
            finally
                fOutputBuffer.endBuffering();
                fcgiProcessor.write(stream, fOutputBuffer.flush());
            end;
        end;
        result := true;
    end;

end.
