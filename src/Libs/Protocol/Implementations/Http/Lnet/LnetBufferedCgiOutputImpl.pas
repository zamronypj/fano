{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetBufferedCgiOutputImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    KeyValuePairIntf,
    ReadyListenerIntf,
    LnetResponseAwareIntf,
    lhttp,
    lwebserver,
    LnetCgiOutputImpl;

type

    TLnetBufferedCgiOutput = class(TLnetCGIOutput)
    private
        fEnvVars : IKeyValuePair;
        fStdInStream : IStreamAdapter;
        fRequestReadyListener : IReadyListener;
        fResponseAware : ILnetResponseAware;
    protected
        (*!------------------------------------------------
         * called when STDIN (body of request) is done read
         * and parsed. Here we will call ready listener
         * to dispatch request to controller
         *-----------------------------------------------*)
        procedure DoneInput(); override;

        (*!------------------------------------------------
         * called when data from STDIN available
         *-----------------------------------------------*)
        function  HandleInput(ABuffer: pchar; ASize: integer): integer; override;

        (*!------------------------------------------------
         * called when environment variable need to be added
         *-----------------------------------------------*)
        procedure AddEnvironment(const AName, AValue: string); override;

        procedure CGIOutputError(); override;

        (*!------------------------------------------------
         * called when we need to write CGI response to socket
         *-----------------------------------------------*)
        function  WriteCGIData(): TWriteBlockStatus; override;
    public
        constructor Create(ASocket: TLHTTPSocket);
        destructor destroy(); override;
        procedure StartRequest(); override;
        property requestReady : IReadyListener read fRequestReadyListener write fRequestReadyListener;
        property responseAware : ILnetResponseAware read fResponseAware write fResponseAware;
    end;

implementation

uses

    Classes,
    Sysutils,
    EnvironmentIntf,
    NullStreamAdapterImpl,
    KeyValueEnvironmentImpl,
    KeyValuePairImpl,
    StreamAdapterImpl;

const

    InputBufferEmptyToWriteStatus: array[boolean] of TWriteBlockStatus =
        (wsPendingData, wsWaitingData);

    constructor TLnetBufferedCgiOutput.create(ASocket: TLHTTPSocket);
    begin
        inherited create(ASocket);
        fEnvVars := TKeyValuePair.create();
        fStdInStream := TStreamAdapter.create(
            TFileStream.create(getTempFilename(), fmCreate)
        );
    end;

    destructor TLnetBufferedCgiOutput.destroy();
    begin
        fEnvVars := nil;
        fStdInStream := nil;
        inherited destroy();
    end;

    procedure TLnetBufferedCgiOutput.AddEnvironment(const AName, AValue: string);
    begin
        fEnvVars.setValue(AName, AValue);
    end;

    procedure TLnetBufferedCgiOutput.CGIOutputError();
    begin
        TLHTTPServerSocket(FSocket).FResponseInfo.Status := hsInternalError;
    end;

    function TLnetBufferedCgiOutput.WriteCGIData(): TWriteBlockStatus;
    var
        lRead: integer;
    begin
        //assume fStreamAdapter is not nil
        lRead := fStreamAdapter.read(FBuffer[FReadPos], FBufferSize-FReadPos);
        if lRead = 0 then
        begin
            exit(wsDone);
        end;

        inc(FReadPos, lRead);
        result := InputBufferEmptyToWriteStatus[lRead = 0];
    end;

    function TLnetBufferedCgiOutput.HandleInput(ABuffer: pchar; ASize: integer): integer;
    begin
        //write body in stdin stream
        result := fStdInStream.write(ABuffer^, ASize);
    end;


    (*!------------------------------------------------
     * called when STDIN (body of request) is done read
     * and parsed. Here we will call ready listener
     * to dispatch request to controller
     *-----------------------------------------------*)
    procedure TLnetBufferedCgiOutput.DoneInput();
    var
        aSockStream : IStreamAdapter;
        aCgiEnv : ICGIEnvironment;
    begin
        //if we get here, body of request is parsed and
        //we have CGI environment ready tell protocol processor so that
        //it can begin dispatching request to controller

        //we will not use socket stream as it is already read and parsed
        //by TLHttpServer
        //TODO: maybe we can improve by providing socket stream implementation
        //which using TLHTTPSocket
        aSockStream := TNullStreamAdapter.create();

        //setup CGI environment
        aCgiEnv := TKeyValueEnvironment.create(fEnvVars);

        if (assigned(fResponseAware)) then
        begin
            //let any response aware object knows ourself
            //that means you, TLnetStdOutWriter!
            fResponseAware.response := self;
        end;

        //let our application handle route dispatching
        fRequestReadyListener.ready(
            aSockStream,
            aCgiEnv,
            fStdInStream
        );

    end;

    procedure TLnetBufferedCgiOutput.StartRequest();
    begin
        //call ancestor so that CGI Environment is built
        inherited StartRequest();

        //parse body of request, this will be our STDIN stream
        //when parseBuffer() complete, DoneInput() will be called
        //which then continue dispatching request to controller
        FSocket.parseBuffer();
    end;

end.
