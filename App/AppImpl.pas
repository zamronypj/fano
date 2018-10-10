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
   DependencyContainerIntf,
   AppIntf,
   DispatcherIntf,
   EnvironmentIntf,
   ErrorHandlerIntf,
   RouteCollectionIntf;

type

    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;

        function initialize(const container : IDependencyContainer) : IRunnable;
        function execute() : IRunnable;
    protected
        procedure buildDependencies(const container : IDependencyContainer); virtual; abstract;
        procedure buildRoutes(const container : IDependencyContainer); virtual; abstract;
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; virtual; abstract;
        function initEnvironment(const container : IDependencyContainer) : ICGIEnvironment;virtual; abstract;
        function initErrorHandler(const container : IDependencyContainer) : IErrorHandler; virtual; abstract;
    public
        constructor create(const container : IDependencyContainer);
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses
    sysutils,
    ResponseIntf,
    ERouteHandlerNotFoundImpl,
    EDependencyNotFoundImpl;

    constructor TFanoWebApplication.create(const container : IDependencyContainer);
    begin
        dispatcher := nil;
        environment := nil;
        errorHandler := nil;
        initialize(container);
    end;

    destructor TFanoWebApplication.destroy();
    begin
        inherited destroy();
        dispatcher := nil;
        environment := nil;
        errorHandler := nil;
    end;

    function TFanoWebApplication.initialize(const container : IDependencyContainer) : IRunnable;
    begin
        buildDependencies(container);
        buildRoutes(container);
        dispatcher := initDispatcher(container);
        environment := initEnvironment(container);
        errorHandler := initErrorHandler(container);
        result := self;
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
