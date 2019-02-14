{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit HttpServerAppImpl;

interface

{$MODE OBJFPC}

uses

    AppIntf,
    ErrorHandlerIntf,
    sysutils,
    fphttpserver;

type

    (*!-----------------------------------------------
     * Decorator class that wrap IWebApplication instance
     * as standalone http server
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFanoHttpServerApplication = class(TInterfacedObject, IWebApplication)
    private
        appInstance : IWebApplication;
        errorHandler : IErrorHandler;
        httpHost : string;
        httpPort : integer;

        procedure setupEnvironment(const ARequest: TFPHTTPConnectionRequest);

        procedure handleRequest(
            sender: TObject;
            var ARequest: TFPHTTPConnectionRequest;
            var AResponse : TFPHTTPConnectionResponse
        );

        procedure handleError(sender: TObject; e : Exception);
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param app other IWebApplication instance
         * @param errHandler error handler
         * @param host hostname/IP address
         * @param port TCP port
         *-----------------------------------------------*)
        constructor create(
            const app : IWebApplication;
            const errHandler : IErrorHandler;
            const host : string = 'localhost';
            const port : integer = 80
        );

        (*!-----------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!-----------------------------------------------
         * execute application and handle exception
         *------------------------------------------------
         * @return current application instance
         *-----------------------------------------------*)
        function run() : IRunnable;
    end;

implementation

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param app other IWebApplication instance
     * @param errHandler error handler
     * @param host hostname/IP address
     * @param port TCP port
     *-----------------------------------------------*)
    constructor TFanoHttpServerApplication.create(
        const app : IWebApplication;
        const errorHandler : IErrorHandler;
        const host : string = 'localhost';
        const port : integer = 80
    );
    begin
        appInstance := app;
        errorHandler := errHandler;
        httpHost := host;
        httpPort := port;
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFanoHttpServerApplication.destroy();
    begin
        inherited destroy();
        appInstance := nil;
        errorHandler := nil;
    end;

    procedure TFanoHttpServerApplication.setupEnvironment(
        const ARequest: TFPHTTPConnectionRequest
    );
    begin
        //TODO:setup CGI environment
    end;

    procedure TFanoHttpServerApplication.handleRequest(
        sender: TObject;
        var ARequest: TFPHTTPConnectionRequest;
        var AResponse : TFPHTTPConnectionResponse
    );
    begin
        setupEnvironment(ARequest);
        appInstance.run();
    end;

    procedure TFanoHttpServerApplication.handleError(sender: TObject; E : Exception);
    begin
        errorHandler.handleError(e);
    end;

    (*!-----------------------------------------------
     * execute application and handle exception
     *------------------------------------------------
     * @return current application instance
     *-----------------------------------------------
     * TODO: need to think about how to execute when
     * application is run as daemon.
     *-----------------------------------------------*)
    function TFanoHttpServerApplication.run() : IRunnable;
    var server : TFPHttpServer;
    begin
        server := TFPHTTPServer.create(nil);
        try
            server.hostName := httpHost;
            server.port := httpPort;
            server.onRequest := @handleRequest;
            server.onRequestError := @handleError;
            server.active := true;
        finally
            freeAndNil(server);
        end;
    end;
end.
