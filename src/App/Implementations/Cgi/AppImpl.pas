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
     * Base CGI application that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCgiWebApplication = class(TCoreWebApplication)
    public
        function run() : IRunnable; override;
    end;

implementation

uses

    SysUtils,

    ///exception-related units
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl,
    EInvalidMethodImpl,
    EInvalidRequestImpl,
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
    function TCgiWebApplication.run() : IRunnable;
    begin
        try
            if (initialize(fAppSvc.container)) then
            begin
                result := execute(fAppSvc.env);
            end;
        except
            on e : EInvalidRequest do
            begin
                fAppSvc.errorHandler.handleError(fAppSvc.env.enumerator, e, 400, sHttp400Message);
                reset();
            end;

            on e : ERouteHandlerNotFound do
            begin
                fAppSvc.errorHandler.handleError(fAppSvc.env.enumerator, e, 404, sHttp404Message);
                reset();
            end;

            on e : EMethodNotAllowed do
            begin
                fAppSvc.errorHandler.handleError(fAppSvc.env.enumerator, e, 405, sHttp405Message);
                reset();
            end;

            on e : EInvalidMethod do
            begin
                fAppSvc.errorHandler.handleError(fAppSvc.env.enumerator, e, 501, sHttp501Message);
                reset();
            end;

            on e : Exception do
            begin
                fAppSvc.errorHandler.handleError(fAppSvc.env.enumerator, e);
                reset();
            end;
        end;
    end;
end.
