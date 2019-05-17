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
    {$IFDEF unix}
    cthreads,
    {$ENDIF}
    Classes,
    SysUtils,
    Sockets,
    fpAsync,
    fpSock,

    RunnableIntf,
    DependencyContainerIntf,
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf;

type

    (*!-----------------------------------------------
     * FastCGI web application that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFastCGIWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        dependencyContainer : IDependencyContainer;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;

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
            const dispatcherInst : IDispatcher
        );
        destructor destroy(); override;
        function run() : IRunnable;
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
        const dispatcherInst : IDispatcher
    );
    begin
        dependencyContainer := container;
        environment :=env;
        errorHandler := errHandler;
        dispatcher := dispatcherInst;
    end;

    destructor TFastCGIWebApplication.destroy();
    begin
        inherited destroy();
        dependencyContainer := nil;
        environment := nil;
        errorHandler := nil;
        dispatcher := nil;
    end;

    function TFastCGIWebApplication.run() : IRunnable;
    var ServerEventLoop: TEventLoop;
    begin
        result := self;
        ServerEventLoop := TEventLoop.Create();
        try
            with TTestServer.Create(nil) do
            begin
                EventLoop := ServerEventLoop;
                Port := 12000;
                WriteLn('Serving...');
                Active := true;
                EventLoop.Run;
            end;
        finally
          ServerEventLoop.Free;
        end;
    end;

end.
