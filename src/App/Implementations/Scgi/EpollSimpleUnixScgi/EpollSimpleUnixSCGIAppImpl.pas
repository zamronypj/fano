{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EpollSimpleUnixSCGIAppImpl;

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
     * SCGI web application as daemon using Unix Domain socket
     *------------------------------------------------------
     * This is base class you need for SCGI web application
     * that is run as daemon with Apache and mod_proxy_scgi module
     * or nginx
     *------------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollSimpleUnixSCGIWebApplication = class(TBaseSimpleSCGIWebApplication)
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

    EpollUnixSocketSvrImpl;

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
    constructor TEpollSimpleUnixSCGIWebApplication.create(
        const socketFilename : string;
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    begin
        inherited create(
            TEpollUnixSocketSvr.create(socketFilename),
            container,
            errHandler,
            dispatcherInst
        );
    end;

end.
