{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LnetFanoHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SyncObjs,
    RunnableIntf,
    RunnableWithDataNotifIntf,
    ProtocolProcessorIntf,
    ReadyListenerIntf,
    DataAvailListenerIntf,
    EnvironmentIntf,
    CloseableIntf,
    StreamIdIntf,
    StreamAdapterIntf,
    lhttp,
    lwebserver,
    LnetResponseAwareIntf,
    HttpSvrConfigTypes;

type

    TLnetFanoHandler = class(TUriHandler)
    private
        fRequestReadyListener : IReadyListener;
    protected
        function HandleURI(ASocket: TLHTTPServerSocket): TOutputItem; override;
    public
        property readyListener : IReadyListener read fRequestReadyListener write fRequestReadyListener;
    end;

implementation


uses

    LnetBufferedCgiOutputImpl;

    function TLnetFanoHandler.HandleURI(ASocket: TLHTTPServerSocket): TOutputItem;
    var
        lOutput: TLnetBufferedCGIOutput;
    begin
        lOutput := TLnetBufferedCGIOutput.create(ASocket);
        lOutput.requestReady := fRequestReadyListener;
        lOutput.startRequest();
        result := lOutput;
    end;

end.

