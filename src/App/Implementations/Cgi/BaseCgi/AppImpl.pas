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
    CoreAppConsts,
    CoreAppImpl;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFanoWebApplication = class(TCoreWebApplication)
    public
        function run() : IRunnable; override;
    end;

implementation

uses

    SysUtils,

    ///exception-related units
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl,
    EDependencyNotFoundImpl,
    EInvalidDispatcherImpl,
    EInvalidFactoryImpl;

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
                errorHandler.handleError(envEnum, e, 404, sHttp404Message);
                reset();
            end;

            on e : EMethodNotAllowed do
            begin
                errorHandler.handleError(envEnum, e, 405, sHttp405Message);
                reset();
            end;

            on e : Exception do
            begin
                errorHandler.handleError(envEnum, e);
                reset();
            end;
        end;
    end;
end.
