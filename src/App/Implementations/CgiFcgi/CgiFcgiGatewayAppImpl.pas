{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FastCGIAppImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RunnableIntf,
    AppIntf;

type

    (*!-----------------------------------------------
     * web application that implements IWebApplication
     * and run as ordinary CGI application or FastCGI application
     * based how application is invoked.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TCGIFastCGIGatewayApplication = class(TInterfacedObject, IWebApplication)
    private
        fCgiApp : IWebApplication;
        fFcgiApp : IWebApplication;

        function isRunAsFastCgi() : boolean;
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param cgiApp instance CGI Application
         * @param fcgiApp instance FastCGI application
         *-----------------------------------------------*)
        constructor create(
            const cgiApp : IWebApplication;
            const fcgiApp : IWebApplication
        );
        destructor destroy(); override;
        function run() : IRunnable; override;

    end;

implementation

uses

    sockets;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param cgiApp instance CGI Application
     * @param fcgiApp instance FastCGI application
     *-----------------------------------------------*)
    constructor TCGIFastCGIGatewayApplication.create(
        const cgiApp : IWebApplication;
        const fcgiApp : IWebApplication
    );
    begin
        inherited create();
        fCgiApp := cgiApp;
        fFcgiApp := fcgiApp;
    end;

    destructor TCGIFastCGIGatewayApplication.destroy();
    begin
        inherited destroy();
        fCgiApp := nil;
        fFcgiApp := nil;
    end;

    function TCGIFastCGIGatewayApplication.isRunAsFastCgi() : boolean;
    var sockAddr :TSockAddr;
        len, err: longint;
    begin
        len := sizeOf(TSockAddr);
        fillChar(sockAddr, len, 0);
        err := fpGetPeerName(FCGI_LISTENSOCK_FILENO, @sockAddr, @len);
        result := (err = -1) and (socketError() = EsockENOTCONN);
    end;

    function TCGIFastCGIGatewayApplication.run() : IRunnable;
    begin
        if (isRunAsFastCgi()) then
        begin
            result := fFcgiApp.run();
        end else
        begin
            result := fCgiApp.run();
        end;
    end;

end.
