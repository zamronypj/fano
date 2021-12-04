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
    lhttp,
    lwebserver;

type

    TLnetBufferedCgiOutput = class(TCGIOutput)
    private
        fStreamAdapter : IStreamAdapter;
        fEnvVars : IKeyValuePair;
        fRequestReadyListener : IReadyListener;

    protected

        procedure AddEnvironment(const AName, AValue: string); override;
        procedure CGIOutputError(); override;
        function  WriteCGIData(): TWriteBlockStatus; override;
    public
        constructor Create(ASocket: TLHTTPSocket);
        procedure startRequest(); override;
        property stream : IStreamAdapter read fStreamAdapter write fStreamAdapter;
        property requestReady : IReadyListener read fRequestReadyListener write fRequestReadyListener;
    end;

implementation

uses

    EnvironmentIntf,
    NullStreamAdapterImpl,
    KeyValueEnvironmentImpl,
    KeyValuePairImpl;

const

    InputBufferEmptyToWriteStatus: array[boolean] of TWriteBlockStatus =
        (wsPendingData, wsWaitingData);

    constructor TLnetBufferedCgiOutput.create(ASocket: TLHTTPSocket);
    begin
        inherited create(ASocket);
        fEnvVars := TKeyValuePair.create();
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

    procedure TLnetBufferedCgiOutput.startRequest();
    var
        aSockStream : IStreamAdapter;
        aCgiEnv : ICGIEnvironment;
    begin
        inherited startRequest();

        //we will not use socket stream as we will have our own IStdOut
        //that write output with TLHttpServer
        aSockStream := TNullStreamAdapter.create();
        aCgiEnv := TKeyValueEnvironment.create(fEnvVars);
        //let our application handle route dispatching
        fRequestReadyListener.ready(
            aSockStream,
            aCgiEnv,
            aSockStream //TODO implement STDIN stream
        );
    end;

end.

