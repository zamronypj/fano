{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadProtocolProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    CloseableIntf,
    ReadyListenerIntf,
    StreamIdIntf,
    ProtocolProcessorIntf;

type

    (*!-----------------------------------------------
     * thread class which wrap single protocol processor
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TProtocolThread = class(TThread)
    private
        fStream : IStreamAdapter;
        fStreamCloser : ICloseable;
        fStreamId : IStreamId;
        fProtocol : IProtocolProcessor;
    protected
        procedure execute(); override;
    public
        constructor create(
            createSuspended : boolean;
            const proto : IProtocolProcessor
        );
        destructor destroy(); override;

        property stream : IStreamAdapter read fStream write fStream;
        property streamCloser : ICloseable read fStreamCloser write fStreamCloser;
        property streamId : IStreamId read fStreamId write fStreamId;
    end;

    TProtocolThreadArray = array of TProtocolThread;

implementation


    constructor TProtocolThread.create(
        createSuspended : boolean;
        const proto : IProtocolProcessor
    );
    begin
        inherited create(createSuspended);
        fProtocol := proto;
        fStream := nil;
        fStreamCloser := nil;
        fStreamId := nil;
    end;

    destructor TProtocolThread.destroy();
    begin
        fProtocol := nil;
        fStream := nil;
        fStreamCloser := nil;
        fStreamId := nil;
        inherited destroy();
    end;

    procedure TProtocolThread.execute();
    begin
        fProtocol.process(fStream, fStreamCloser, fStreamId);
    end;

end.
