{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetBufferredCgiOutputImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    lhttp,
    lwebserver;

type

    TLnetBufferredCgiOutput = class(TCGIOutput)
    private
        fStreamAdapter : IStreamAdapter;
        fEnvVars : IKeyValuePair;

        procedure setStream(astreamAdapter: IStreamAdapter);
    protected

        procedure AddEnvironment(const AName, AValue: string); override;
        procedure CGIOutputError(); override;
        function  WriteCGIData(): TWriteBlockStatus; override;
    public
        constructor Create(ASocket: TLHTTPSocket);
        procedure startRequest();
        property stream : IStreamAdapter read fStreamAdapter write setStream;
    end;

implementation

const

    InputBufferEmptyToWriteStatus: array[boolean] of TWriteBlockStatus =
        (wsPendingData, wsWaitingData);

    constructor TLnetBufferredCgiOutput.create(ASocket: TLHTTPSocket);
    begin
        inherited create(ASocket);
        fEnvVars := TKeyValuePair.create();
    end;

    procedure TLnetBufferredCgiOutput.setStream(astreamAdapter: IStreamAdapter);
    begin
        fStreamAdapter := astreamAdapter;
    end;

    procedure TLnetBufferredCgiOutput.AddEnvironment(const AName, AValue: string);
    begin
        fEnvVars.setValue(AName, AValue);
    end;

    procedure TLnetBufferredCgiOutput.CGIOutputError();
    begin
        TLHTTPServerSocket(FSocket).FResponseInfo.Status := hsInternalError;
    end;

    function TLnetBufferredCgiOutput.WriteCGIData(): TWriteBlockStatus;
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

    procedure TLnetBufferredCgiOutput.startRequest();
    var
        aSockStream : IStreamAdapter;
        aCgiEnv : ICGIEnvironment;
    begin
        //we will not use socket stream as we will have our own IStdOut
        //that write output with TLHttpServer
        aSockStream := TNullStreamAdapter.create();
        aCgiEnv := TKeyValueEnvironment.create(fEnvVars);
        //let our application handle route dispatching
        fRequestReadyListener.ready(
            //we will not use socket stream as we will have our own IStdOut
            //that write output with TLHttpServer
            aSockStream,
            aCgiEnv,
            TStreamAdapter.create(TStringStream.create(request.content))
        );
    end;

end.

