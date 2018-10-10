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
        dependencyContainer : IDependencyContainer;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;

        function execute() : IRunnable;
        procedure reset();
        function initialize(const container : IDependencyContainer) : boolean;
    protected
        procedure buildDependencies(const container : IDependencyContainer); virtual; abstract;
        procedure buildRoutes(const container : IDependencyContainer); virtual; abstract;
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; virtual; abstract;
    public
        constructor create(
            const container : IDependencyContainer;
            const env : ICGIEnvironment;
            const errHandler : IErrorHandler
        );
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses
    sysutils,
    ResponseIntf,

    ///exception-related units
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl,
    EDependencyNotFoundImpl;

    procedure TFanoWebApplication.reset();
    begin
        dispatcher := nil;
        environment := nil;
        errorHandler := nil;
        dependencyContainer := nil;
    end;

    constructor TFanoWebApplication.create(
        const container : IDependencyContainer;
        const env : ICGIEnvironment;
        const errHandler : IErrorHandler
    );
    begin
        reset();
        environment := env;
        errorHandler := errHandler;
        dependencyContainer := container;
    end;

    destructor TFanoWebApplication.destroy();
    begin
        inherited destroy();
        reset();
    end;

    function TFanoWebApplication.initialize(const container : IDependencyContainer) : boolean;
    begin
        buildDependencies(container);
        buildRoutes(container);
        dispatcher := initDispatcher(container);
        result := true;
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
            if (initialize(dependencyContainer)) then
            begin
                result := execute();
            end;
        except
            on e : ERouteHandlerNotFound do
            begin
                errorHandler.handleError(e, 404, 'Not Found');
                reset();
            end;

            on e : EMethodNotAllowed do
            begin
                errorHandler.handleError(e, 405, 'Method Not Allowed');
                reset();
            end;

            on e : EDependencyNotFound do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : EAccessViolation do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : Exception do
            begin
                errorHandler.handleError(e);
                reset();
            end;
        end;
    end;
end.
