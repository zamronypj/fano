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
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    DataAvailListenerIntf,
    RunnableWithDataNotifIntf;

type

    (*!-----------------------------------------------
     * FastCGI web application that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFastCGIWebApplication = class(TInterfacedObject, IWebApplication, IRunnable, IDataAvailListener)
    private
        dependencyContainer : IDependencyContainer;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;
        workerServer : RunnableWithDataNotifIntf;
        fcgiParser : IFcgiFrameParser;
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
            const env : ICGIEnvironment;
            const errHandler : IErrorHandler;
            const dispatcherInst : IDispatcher;
            const server : IRunnableWithDataNotif;
            const parser : IFcgiFrameParser
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
        const env : ICGIEnvironment;
        const errHandler : IErrorHandler;
        const dispatcherInst : IDispatcher;
        const server : IRunnableWithDataNotif;
        const parser : IFcgiFrameParser
    );
    begin
        dependencyContainer := container;
        environment :=env;
        errorHandler := errHandler;
        dispatcher := dispatcherInst;
        workerServer := server;
        fcgiParser := parser;
    end;

    destructor TFastCGIWebApplication.destroy();
    begin
        inherited destroy();
        dependencyContainer := nil;
        environment := nil;
        errorHandler := nil;
        dispatcher := nil;
        workerServer := nil;
    end;

    function TFastCGIWebApplication.run() : IRunnable;
    begin
        workerServer.setDataAvailListener(self).run();
        result := self;
    end;

    function TFastCGIWebApplication.handleData(const stream : IStreamAdapter; const context : TObject) : boolean;
    var arecord : IFcgiRecord;
    begin
        if (fcgiParser.hasFrame(stream)) then
        begin
            arecord := fcgiParser.parseFrame(stream);
            //TODO: handle record and output appropriate response
        end;
        result := true;
    end;

end.
