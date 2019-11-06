{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EpollSimpleUwsgiAppImpl;

interface

{$MODE OBJFPC}

uses

    BaseSimpleUwsgiAppImpl,
    DependencyContainerIntf,
    DispatcherIntf,
    ErrorHandlerIntf;

type

    (*!-----------------------------------------------
     * Base abstract class that implements IWebApplication
     * and provide basic default for easier setup for
     * SCGI web application as daemon using TCP
     *------------------------------------------------------
     * This is base class you need for SCGI web application
     * that is run as daemon with Apache and mod_proxy_scgi module
     * or nginx
     *------------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollSimpleUwsgiWebApplication = class(TBaseSimpleUwsgiWebApplication)
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param hostname hostname where daemon lister
         * @param port port where daemon lister
         * @param container dependency container
         * @param errHandler error handler
         * @param dispatcher, dspatcher instance instance
         *----------------------------------------------
         * This is provided to simplify thing by providing
         * default service provider
         *-----------------------------------------------*)
        constructor create(
            const hostname : string;
            const port : word;
            const container : IDependencyContainer = nil;
            const errHandler : IErrorHandler = nil;
            const dispatcherInst : IDispatcher = nil
        );

    end;

implementation

uses

    EpollInetSocketSvrImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param hostname hostname where daemon lister
     * @param port port where daemon lister
     * @param container dependency container
     * @param errHandler error handler
     * @param dispatcher, dspatcher instance instance
     *----------------------------------------------
     * This is provided to simplify thing by providing
     * default service provider
     *-----------------------------------------------*)
    constructor TEpollSimpleUwsgiWebApplication.create(
        const hostname : string;
        const port : word;
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    begin
        inherited create(
            TEpollInetSocketSvr.create(hostname, port),
            container,
            errHandler,
            dispatcherInst
        );
    end;

end.
