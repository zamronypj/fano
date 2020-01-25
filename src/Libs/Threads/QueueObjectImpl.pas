{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit QueueObjectImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    CloseableIntf,
    StreamAdapterIntf,
    StreamIdIntf,
    RunnableIntf,
    ProtocolProcessorIntf;

type

    TQueueObject = class(TInterfacedObject, IRunnable)
    private
        fProtocol : IProtocolProcessor;
        fstream : IStreamAdapter;
        fcontext : TObject;
        fstreamCloser : ICloseable;
        fstreamId : IStreamId;
    public
        constructor create(
            const stream : IStreamAdapter;
            const context : TObject;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        );
        destructor destroy(); override;
        function run() : IRunnable;
    end;


implementation

    constructor TQueueObject.create(
        const protocolProcessor : IProtocolProcessor;
        const stream : IStreamAdapter;
        const context : TObject;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    );
    begin
        fProtocol := protocolProcessor;
        fstream := stream;
        fcontext := context;
        fstreamCloser := streamCloser;
        fstreamId := streamId;
    end;

    destructor TQueueObject.destroy();
    begin
        fProtocol := nil;
        fstream := nil;
        fcontext := nil;
        fstreamCloser := nil;
        fstreamId := nil;
        inherited destroy();
    end;

    function TQueueObject.run() : IRunnable;
    begin
        fProtocol.process(fstream, fstreamCloser, fStreamId);
        result := self;
    end;


end.
