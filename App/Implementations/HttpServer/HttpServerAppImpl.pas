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
    EnvironmentWriterIntf,
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
        envWriter : IEnvironmentWriter;
        errorHandler : IErrorHandler;
        httpHost : string;
        httpPort : integer;

        procedure setupEnvironment(const ARequest: TFPHTTPConnectionRequest);

        procedure handleRequest(
            sender: TObject;
            var aRequest: TFPHTTPConnectionRequest;
            var aResponse : TFPHTTPConnectionResponse
        );

        procedure handleError(sender: TObject; e : Exception);
    public

        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param app other IWebApplication instance
         * @param env environment writer
         * @param errHandler error handler
         * @param host hostname/IP address
         * @param port TCP port
         *-----------------------------------------------*)
        constructor create(
            const app : IWebApplication;
            const env : IEnvironmentWriter;
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
        const env : IEnvironmentWriter;
        const errorHandler : IErrorHandler;
        const host : string = 'localhost';
        const port : integer = 80
    );
    begin
        appInstance := app;
        envWriter := env;
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
        envWriter := nil;
        errorHandler := nil;
    end;

    procedure TFanoHttpServerApplication.setupEnvironment(
        const aRequest: TFPHTTPConnectionRequest
    );
    begin
        //setup CGI environment
        envWriter.setEnv('REQUEST_METHOD', aRequest.method);
        envWriter.setEnv('REQUEST_URI', aRequest.url);
        envWriter.setEnv('CONTENT_TYPE', aRequest.contentType);
        envWriter.setEnv('CONTENT_LENGTH', inttostr(aRequest.contentLength));
        envWriter.setEnv('REMOTE_ADDR', aRequest.remoteAddr);
        envWriter.setEnv('SCRIPT_NAME', aRequest.scriptName);
        envWriter.setEnv('HTTP_USER_AGENT', aRequest.userAgent);
        envWriter.setEnv('HTTP_REFERRER', aRequest.referrer);
        envWriter.setEnv('HTTP_COOKIE', aRequest.cookie);
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
