{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit AppImpl;

interface

{$MODE OBJFPC}

uses
    RunnableIntf,
    DependencyContainerIntf,
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFanoWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        dependencyContainer : IDependencyContainer;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        errorHandler : IErrorHandler;

        (*!-----------------------------------------------
         * execute application and write response
         *------------------------------------------------
         * @return current application instance
         *-----------------------------------------------
         * TODO: need to think about how to execute when
         * application is run as daemon.
         *-----------------------------------------------*)
        function execute() : IRunnable;

        procedure reset();

        (*!-----------------------------------------------
         * initialize application dependencies
         *------------------------------------------------
         * @param container dependency container
         * @return true if application dependency succesfully
         * constructed
         *-----------------------------------------------*)
        function initialize(const container : IDependencyContainer) : boolean;

        (*!-----------------------------------------------
         * Build application route dispatcher
         *------------------------------------------------
         * @param container dependency container
         *-----------------------------------------------*)
        procedure buildDispatcher(const container : IDependencyContainer);
    protected

        (*!-----------------------------------------------
         * Build application dependencies
         *------------------------------------------------
         * @param container dependency container
         *-----------------------------------------------*)
        procedure buildDependencies(const container : IDependencyContainer); virtual; abstract;

        (*!-----------------------------------------------
         * Build application routes
         *------------------------------------------------
         * @param container dependency container
         *-----------------------------------------------*)
        procedure buildRoutes(const container : IDependencyContainer); virtual; abstract;

        (*!-----------------------------------------------
         * initialize application route dispatcher
         *------------------------------------------------
         * @param container dependency container
         * @return dispatcher instance
         *-----------------------------------------------*)
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; virtual; abstract;
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param container dependency container
         * @param env CGI environment instance
         * @param errHandler error handler
         *-----------------------------------------------*)
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
    EDependencyNotFoundImpl,
    EInvalidDispatcherImpl,
    EInvalidFactoryImpl;

resourcestring

    sHttp404Message = 'Not Found';
    sHttp405Message = 'Method Not Allowed';
    sErrInvalidDispatcher = 'Dispatcher instance is invalid';

    procedure TFanoWebApplication.reset();
    begin
        dispatcher := nil;
        environment := nil;
        errorHandler := nil;
        dependencyContainer := nil;
    end;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param container dependency container
     * @param env CGI environment instance
     * @param errHandler error handler
     *-----------------------------------------------
     * errHandler is injected as application dependencies
     * instead of using dependency container because
     * we need to make sure that during building
     * application dependencies and routes, if something
     * goes wrong, we can be sure that there is error handler
     * to handle the exception
     *-----------------------------------------------*)
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

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFanoWebApplication.destroy();
    begin
        inherited destroy();
        reset();
    end;

    (*!-----------------------------------------------
     * Build application route dispatcher
     *------------------------------------------------
     * @param container dependency container
     * @throws EInvalidDispatcher
     *-----------------------------------------------
     * route dispatcher is essentials but because
     * we allow user to use IDispatcher
     * implementation they like, we need to be informed
     * about it.
     *-----------------------------------------------*)
    procedure TFanoWebApplication.buildDispatcher(const container : IDependencyContainer);
    begin
        dispatcher := initDispatcher(container);
        if (dispatcher = nil) then
        begin
            raise EInvalidDispatcher.create(sErrInvalidDispatcher);
        end;
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
    function TFanoWebApplication.initialize(const container : IDependencyContainer) : boolean;
    begin
        buildDependencies(container);
        buildRoutes(container);
        buildDispatcher(container);
        result := true;
    end;

    (*!-----------------------------------------------
     * execute application and write response
     *------------------------------------------------
     * @return current application instance
     *-----------------------------------------------
     * TODO: need to think about how to execute when
     * application is run as daemon.
     *-----------------------------------------------*)
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

    (*!-----------------------------------------------
     * execute application and handle exception
     *------------------------------------------------
     * @return current application instance
     *-----------------------------------------------
     * TODO: need to think about how to execute when
     * application is run as daemon.
     *-----------------------------------------------*)
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
                errorHandler.handleError(e, 404, sHttp404Message);
                reset();
            end;

            on e : EMethodNotAllowed do
            begin
                errorHandler.handleError(e, 405, sHttp405Message);
                reset();
            end;

            on e : EDependencyNotFound do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : EInvalidDispatcher do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : EInvalidFactory do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : EAccessViolation do
            begin
                errorHandler.handleError(e);
                reset();
            end;

            on e : EInOutError do
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
