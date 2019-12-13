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
    AppServiceProviderIntf,
    DispatcherIntf,
    EnvironmentIntf,
    EnvironmentEnumeratorIntf,
    ErrorHandlerIntf,
    StdInIntf,
    RouterIntf,
    CoreAppConsts;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCoreWebApplication = class abstract (TInterfacedObject, IWebApplication, IRunnable)
    protected
        fAppSvc : IAppServiceProvider;

        (*!-----------------------------------------------
         * execute application and write response
         *------------------------------------------------
         * @return current application instance
         *-----------------------------------------------
         * TODO: need to think about how to execute when
         * application is run as daemon.
         *-----------------------------------------------*)
        function execute(const env : ICGIEnvironment) : IRunnable;

        procedure reset();

        (*!-----------------------------------------------
         * initialize application dependencies
         *------------------------------------------------
         * @param container dependency container
         * @return true if application dependency succesfully
         * constructed
         *-----------------------------------------------*)
        function initialize(const container : IDependencyContainer) : boolean; virtual;
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param appSvc class provide essentials service
         *-----------------------------------------------*)
        constructor create(const appSvc : IAppServiceProvider);
        destructor destroy(); override;
        function run() : IRunnable; virtual; abstract;
    end;

implementation

uses

    SysUtils,
    ResponseIntf;

    procedure TCoreWebApplication.reset();
    begin
        fAppSvc := nil;
    end;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param appSvc class that provide essentials services
     *-----------------------------------------------*)
    constructor TCoreWebApplication.create(const appSvc : IAppServiceProvider);
    begin
        inherited create();
        randomize();
        reset();
        fAppSvc := appSvc;
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
        fAppSvc.register(container);
        fAppSvc.routeBuilder.buildRoutes(container, fAppSvc.router);
        result := true;
    end;

    (*!-----------------------------------------------
     * execute application and write response
     *------------------------------------------------
     * @return current application instance
     *-----------------------------------------------*)
    function TCoreWebApplication.execute(const env : ICGIEnvironment) : IRunnable;
    var response : IResponse;
    begin
        response := fAppSvc.dispatcher.dispatchRequest(env, fAppSvc.stdIn);
        try
            response.write();
            result := self;
        finally
            response := nil;
        end;
    end;

end.
