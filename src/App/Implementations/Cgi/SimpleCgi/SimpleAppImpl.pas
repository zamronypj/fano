{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SimpleAppImpl;

interface

{$MODE OBJFPC}

uses
    AppImpl,
    DependencyContainerIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     * and provide basic default for easier setup
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleWebApplication = class(TFanoWebApplication)
    protected
        function initDispatcher(const container : IDependencyContainer) : IDispatcher; override;
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
            const container : IDependencyContainer = nil;
            const env : ICGIEnvironment = nil;
            const errHandler : IErrorHandler  = nil
        );

    end;

implementation

uses

    DependencyContainerImpl,
    DependencyListImpl,
    EnvironmentImpl,
    ErrorHandlerImpl,
    RouteMatcherIntf,
    SimpleRouterFactoryImpl,
    SimpleDispatcherFactoryImpl,
    StdInReaderImpl,
    StdInIntf;

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
    constructor TSimpleWebApplication.create(
        const container : IDependencyContainer = nil;
        const env : ICGIEnvironment = nil;
        const errHandler : IErrorHandler = nil
    );
    var appContainer :  IDependencyContainer;
        appEnv : ICGIEnvironment;
        appErr : IErrorHandler;
        appStdIn : IStdIn;
    begin
        appContainer := container;
        if (appContainer = nil) then
        begin
            appContainer := TDependencyContainer.create(TDependencyList.create());
        end;

        appEnv := env;
        if (appEnv = nil) then
        begin
            appEnv := TCGIEnvironment.create();
        end;

        appErr := errHandler;
        if (appErr = nil) then
        begin
            appErr := TErrorHandler.create();
        end;

        if (not appContainer.has('router')) then
        begin
            appContainer.add('router', TSimpleRouterFactory.create());
        end;

        if (not appContainer.has('dispatcher')) then
        begin
            appContainer.add(
                'dispatcher',
                TSimpleDispatcherFactory.create(
                    appContainer.get('router') as IRouteMatcher
                )
            );
        end;

        appStdIn := TStdInReader.create();

        inherited create(appContainer, appEnv, appErr, appStdIn);
    end;

    function TSimpleWebApplication.initDispatcher(const container : IDependencyContainer) : IDispatcher;
    begin
        result := container.get('dispatcher') as IDispatcher;
    end;
end.
