{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit CoreAppImpl;

interface

{$MODE OBJFPC}

uses

    RunnableIntf,
    DependencyContainerIntf,
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    EnvironmentEnumeratorIntf,
    ErrorHandlerIntf,
    CoreAppConsts;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCoreWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    protected
        dependencyContainer : IDependencyContainer;
        dispatcher : IDispatcher;
        environment : ICGIEnvironment;
        envEnum : ICGIEnvironmentEnumerator;
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
        function initialize(const container : IDependencyContainer) : boolean; virtual;

        (*!-----------------------------------------------
         * Build application route dispatcher
         *------------------------------------------------
         * @param container dependency container
         *-----------------------------------------------*)
        procedure buildDispatcher(const container : IDependencyContainer);

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
        function run() : IRunnable; virtual; abstract;
    end;

implementation

uses

    SysUtils,
    ResponseIntf,

    ///exception-related units
    EInvalidDispatcherImpl;

    procedure TCoreWebApplication.reset();
    begin
        dispatcher := nil;
        environment := nil;
        envEnum := nil;
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
    constructor TCoreWebApplication.create(
        const container : IDependencyContainer;
        const env : ICGIEnvironment;
        const errHandler : IErrorHandler
    );
    begin
        inherited create();
        randomize();
        reset();
        environment := env;
        envEnum := env as ICGIEnvironmentEnumerator;
        errorHandler := errHandler;
        dependencyContainer := container;
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TCoreWebApplication.destroy();
    begin
        reset();
        inherited destroy();
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
    procedure TCoreWebApplication.buildDispatcher(const container : IDependencyContainer);
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
    function TCoreWebApplication.initialize(const container : IDependencyContainer) : boolean;
    begin
        buildDependencies(container);
        buildRoutes(container);
        buildDispatcher(container);

        if envEnum = nil then
        begin
            envEnum := environment as ICGIEnvironmentEnumerator;
        end;

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
    function TCoreWebApplication.execute() : IRunnable;
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

end.
