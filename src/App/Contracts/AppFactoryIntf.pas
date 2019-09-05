{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AppFactoryIntf;

interface

{$MODE OBJFPC}

uses

    AppIntf,
    DependencyContainerIntf,
    DispatcherIntf,
    ErrorHandlerIntf,
    StdInIntf,
    StdOutIntf,
    ProtocolProcessorIntf,
    OutputBufferIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to create
     * IWebApplication instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IWebApplicationFactory = interface
        ['{47D5B42D-6735-47E3-A789-5C51E874B368}']

        function container(const acontainer : IDependencyContainer) : IWebApplicationFactory;
        function errorHandler(const aerrorHandler : IErrorHandler) : IWebApplicationFactory;
        function dispatcher(const aDispatcher : IDispatcher) : IWebApplicationFactory;
        function stdIn(const astdIn : IStdIn) : IWebApplicationFactory;
        function stdOut(const astdOut : IStdOut) : IWebApplicationFactory;
        function protocol(const aProtocol : IProtocolProcessor) : IWebApplicationFactory;
        function outputBuffer(const aOutBuffer : IOutputBuffer) : IWebApplicationFactory;
        function useSession(const useSess : boolean) : IWebApplicationFactory;

        function build() : IWebApplication;
    end;

implementation

end.
