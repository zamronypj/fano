{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SimpleUnixFastCGIAppImpl;

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
     * FastCGI web application as daemon using Unix Domain socket
     *------------------------------------------------------
     * This is base class you need for FastCGI web application
     * that is run as daemon with Apache and mod_proxy_fcgi module
     * or nginx
     *------------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSimpleUnixFastCGIWebApplication = class(TBaseSimpleFastCGIWebApplication)
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param socketFilename socket file where to listen
         * @param container dependency container
         * @param errHandler error handler
         * @param dispatcher, dspatcher instance instance
         *----------------------------------------------
         * This is provided to simplify thing by providing
         * default service provider
         *-----------------------------------------------*)
        constructor create(
            const socketFilename : string;
            const container : IDependencyContainer = nil;
            const errHandler : IErrorHandler = nil;
            const dispatcherInst : IDispatcher = nil
        );

    end;

implementation

uses

    UnixSocketSvrImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param socketFilename socket file where to listen
     * @param container dependency container
     * @param errHandler error handler
     * @param dispatcher, dspatcher instance instance
     *----------------------------------------------
     * This is provided to simplify thing by providing
     * default service provider
     *-----------------------------------------------*)
    constructor TSimpleUnixFastCGIWebApplication.create(
        const socketFilename : string;
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    begin
        inherited create(
            TUnixSocketSvr.create(socketFilename),
            container,
            errHandler,
            dispatcherInst
        );
    end;

end.
