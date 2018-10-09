{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit AppImpl;

interface

uses
   RunnableIntf,
   AppIntf,
   DispatcherIntf,
   EnvironmentIntf,
   ErrorHandlerIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;

        function execute() : IRunnable;
    public
        constructor create(
            const dispatcherInst : IDispatcher;
            const env : ICGIEnvironment;
            const errorHandlerInst : IErrorHandler
        ); virtual;
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses
    sysutils,
    ResponseIntf,
    ERouteHandlerNotFoundImpl,
    EDependencyNotFoundImpl;

    constructor TFanoWebApplication.create(
        const dispatcherInst : IDispatcher;
        const env : ICGIEnvironment;
        const errorHandlerInst : IErrorHandler
    );
    begin
        dispatcher := dispatcherInst;
        environment := env;
        errorHandler := errorHandlerInst;
    end;

    destructor TFanoWebApplication.destroy();
    begin
        inherited destroy();
        dispatcher := nil;
        environment := nil;
        errorHandler := nil;
    end;

    function TFanoWebApplication.execute() : IRunnable;
    var response : IResponse;
    begin
        response := dispatcher.dispatchRequest(environment);
        try
            response.write();
            result := self;
        finally
            response := nil;
        end;
    end;

    function TFanoWebApplication.run() : IRunnable;
    begin
        try
            result := execute();
        except
            on e : ERouteHandlerNotFound do
            begin
                errorHandler.handleError(e);
            end;

            on e : EDependencyNotFound do
            begin
                errorHandler.handleError(e);
            end;

            on e : Exception do
            begin
                errorHandler.handleError(e);
            end;
        end;
    end;
end.
