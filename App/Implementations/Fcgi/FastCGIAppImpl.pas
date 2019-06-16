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
    StdOutIntf,
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
        fStdOutWriter : IStdOut;
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
            const outputBuffer : IOutputBuffer;
            const stdOutWriter : IStdOut
        );
        destructor destroy(); override;
        function run() : IRunnable;

        function handleData(const stream : IStreamAdapter; const context : TObject) : boolean;
    end;

implementation

uses

    SysUtils,
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl;

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
    constructor TFastCGIWebApplication.create(
        const container : IDependencyContainer;
        const errHandler : IErrorHandler;
        const dispatcherInst : IDispatcher;
        const server : IRunnableWithDataNotif;
        const aFcgiProcessor : IFcgiProcessor;
        const outputBuffer : IOutputBuffer;
        const stdOutWriter : IStdOut
    );
    begin
        inherited create(container, nil, errHandler);
        dispatcher := dispatcherInst;
        workerServer := server;
        fcgiProcessor := aFcgiProcessor;
        fOutputBuffer := outputBuffer;
        fStdOutWriter := stdOutWriter;
    end;

    destructor TFastCGIWebApplication.destroy();
    begin
        inherited destroy();
        dispatcher := nil;
        workerServer := nil;
        fcgiProcessor := nil;
        fOutputBuffer := nil;
        fStdOutWriter := nil;
    end;

    (*!-----------------------------------------------
     * initialize application dependencies
     *------------------------------------------------
     * @param container dependency container
     * @return true if application dependency succesfully
     * constructed
     *-----------------------------------------------*)
    function TFastCGIWebApplication.initialize(const container : IDependencyContainer) : boolean;
    begin
        inherited initialize(container);
        workerServer.setDataAvailListener(self);
        result := true;
    end;

    (*!-----------------------------------------------
     * run application
     *------------------------------------------------
     * @return current instance.
     *-----------------------------------------------
     * Note that run keeps run until application is terminated
     *-----------------------------------------------*)
    function TFastCGIWebApplication.run() : IRunnable;
    begin
        if (initialize(dependencyContainer)) then
        begin
            //execute run loop until terminated
            workerServer.run();
        end;
        result := self;
    end;

    (*!-----------------------------------------------
     * execute request
     *------------------------------------------------
     * @param env, CGI environment
     *-----------------------------------------------*)
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

    (*!-----------------------------------------------
     * called when socket contain data available to be
     * processed
     *------------------------------------------------
     * @param stream, socket stream
     * @param context, additional related data related,
     *        mostly contain sender (if any)
     *-----------------------------------------------*)
    function TFastCGIWebApplication.handleData(const stream : IStreamAdapter; const context : TObject) : boolean;
    begin
        if (fcgiProcessor.process(stream)) then
        begin
            //buffer STDOUT, so any write()/writeln() will be buffered to stream
            fOutputBuffer.beginBuffering();
            try
                //when we get here, CGI environment and any POST data are ready
                executeRequest(fcgiProcessor.getEnvironment());
            finally
                fOutputBuffer.endBuffering();
                //write response back to web server (i.e FastCGI client)
                fStdOutWriter.setStream(stream).write(fOutputBuffer.flush());
            end;
        end;
        result := true;
    end;

end.
