{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EpollSimpleSockFastCGIAppImpl;

interface

{$MODE OBJFPC}

uses

    BaseSimpleFastCGIAppImpl,
    DependencyContainerIntf,
    DispatcherIntf,
    ErrorHandlerIntf;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     * and provide basic default for easier setup for
     * FastCGI web application using
     * webserver bound socket FCGI_LISTENSOCK_FILENO.
     *-----------------------------------------------------
     * This is base class you need for FastCGI web application
     * that is invoked by web server such as Apache with mod_fcgid module
     *------------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollSimpleSockFastCGIWebApplication = class(TBaseSimpleFastCGIWebApplication)
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param container dependency container
         * @param errHandler error handler
         * @param dispatcher, dspatcher instance instance
         *----------------------------------------------
         * This is provided to simplify thing by providing
         * default service provider
         *-----------------------------------------------*)
        constructor create(
            const container : IDependencyContainer = nil;
            const errHandler : IErrorHandler = nil;
            const dispatcherInst : IDispatcher = nil
        );

    end;

implementation

uses

    fastcgi,
    EpollBoundSocketSvrImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param container dependency container
     * @param errHandler error handler
     * @param dispatcher, dspatcher instance instance
     *----------------------------------------------
     * This is provided to simplify thing by providing
     * default service provider
     *-----------------------------------------------*)
    constructor TEpollSimpleSockFastCGIWebApplication.create(
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    begin
        inherited create(
            TEpollBoundSocketSvr.create(FCGI_LISTENSOCK_FILENO),
            container,
            errHandler,
            dispatcherInst
        );
    end;

end.
