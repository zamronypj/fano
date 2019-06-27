{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SimpleSockFastCGIAppImpl;

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
    TSimpleSockFastCGIWebApplication = class(TBaseSimpleFastCGIWebApplication)
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

    ListenSockWorkerServerImpl;

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
    constructor TSimpleSockFastCGIWebApplication.create(
        const container : IDependencyContainer = nil;
        const errHandler : IErrorHandler = nil;
        const dispatcherInst : IDispatcher = nil
    );
    begin
        inherited create(
            TListenSockWorkerServer.create(),
            container,
            errHandler,
            dispatcherInst
        );
    end;

end.
