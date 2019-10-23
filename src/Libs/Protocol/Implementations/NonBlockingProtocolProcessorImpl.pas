{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NonBlockingProtocolProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    StreamAdapterIntf,
    CloseableIntf,
    StreamIdIntf,
    ReadyListenerIntf,
    ProtocolProcessorIntf;

type

    TBuffInfo = record
        id : shortstring;
        buffer : IStreamAdapter;
    end;

    PBuffInfo = ^TBuffInfo;

    (*!-----------------------------------------------
     * class having capability to process
     * stream from web server in non-blocking fashion
     * this class basically just collect all data until
     * it is completed, then it calls actual processor
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TNonBlockingProtocolProcessor = class(TInterfacedObject, IProtocolProcessor)
    private
        fBuffLists : IList;
        fActualProcessor : IProtocolProcessor;

        procedure clearBuffers();

        function nonBlockingCopyStream(
            const sockStream : IStreamAdapter;
            const buffInfo : PBuffInfo;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        ) : longint;

        function nonBlockingCopyBuffer(
            const sockStream : IStreamAdapter;
            const buffInfo : PBuffInfo;
            const buff : pointer;
            const buffSize : integer;
            var keepReading : boolean
        ) : longint;

        procedure processBuffer(
            buff : PBuffInfo;
            const stream : IStreamAdapter;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        );
    protected
        function getMinimumBytes() : integer;
    public
        constructor create(
            const actualProcessor : IProtocolProcessor;
            const buffList : IList
        );
        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------*)
        procedure process(
            const stream : IStreamAdapter;
            const streamCloser : ICloseable;
            const streamId : IStreamId
        );

        (*!------------------------------------------------
         * get StdIn stream for complete request
         *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;

        (*!------------------------------------------------
         * set listener to be notified when request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    end;

implementation

uses

    SysUtils,
    Classes,
    BaseUnix,
    StreamAdapterImpl,
    SegregatedStreamAdapterImpl,
    ESockStreamImpl,
    ESockWouldBlockImpl;

    constructor TNonBlockingProtocolProcessor.create(
        const actualProcessor : IProtocolProcessor;
        const buffList : IList
    );
    begin
        inherited create();
        fActualProcessor := actualProcessor;
        fBuffLists := buffList;
    end;

    destructor TNonBlockingProtocolProcessor.destroy();
    begin
        clearBuffers();
        fBuffLists := nil;
        fActualProcessor := nil;
        inherited destroy();
    end;

    procedure TNonBlockingProtocolProcessor.clearBuffers();
    var i, len : integer;
        buff : PBuffInfo;
    begin
        len := fBuffLists.count();
        for i := len -1 downto 0 do
        begin
            buff := fBuffLists.get(i);
            fBuffLists.delete(i);
            buff^.buffer := nil;
            dispose(buff);
        end;
    end;

    (*!------------------------------------------------
     * get minimum bytes of data to process
     * for example, a FCGI record at least require 8 bytes
     * to be usable to be processed.
     *-----------------------------------------------*)
    function TNonBlockingProtocolProcessor.getMinimumBytes() : integer;
    begin
        result := 0;
    end;

    function TNonBlockingProtocolProcessor.nonBlockingCopyBuffer(
        const sockStream : IStreamAdapter;
        const buffInfo : PBuffInfo;
        const buff : pointer;
        const buffSize : integer;
        var keepReading : boolean
    ) : longint;
    var bytesRead : longint;
    begin
        try
            bytesRead := sockStream.read(buff^, buffSize);
            if (bytesRead > 0) then
            begin
                buffInfo^.buffer.write(buff^, bytesRead);
            end;
            result := bytesRead;
        except
            on e : ESockWouldBlock do
            begin
                result := e.errCode;
                keepReading := false;
            end;
        end;
    end;

    function TNonBlockingProtocolProcessor.nonBlockingCopyStream(
        const sockStream : IStreamAdapter;
        const buffInfo : PBuffInfo;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    ) : longint;
    const BUFF_SIZE = 4096;
    var buff : pointer;
        keepReading : boolean;
    begin
        getMem(buff, BUFF_SIZE);
        try
            keepReading := true;
            result := 0;
            while keepReading do
            begin
                result := nonBlockingCopyBuffer(
                    sockStream,
                    buffInfo,
                    buff,
                    BUFF_SIZE,
                    keepReading
                );
            end;
        finally
            freeMem(buff);
        end;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    procedure TNonBlockingProtocolProcessor.processBuffer(
        buff : PBuffInfo;
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    );
    var segStream : IStreamAdapter;
    begin
        if (buff^.buffer.size() > getMinimumBytes()) then
        begin
            //we use segregated stream, so that we can read from data in memory
            //but write to socket
            segStream := TSegregatedStreamAdapter.create(buff^.buffer, stream);
            buff^.buffer.seek(0, soFromBeginning);
            fActualProcessor.process(segStream, streamCloser, streamId);
            //data has been processed, remove buffer.
            fBuffLists.delete(fBuffLists.indexOf(buff^.id));
            buff^.buffer := nil;
            dispose(buff);
        end;
    end;

    (*!------------------------------------------------
     * process request stream
     *-----------------------------------------------*)
    procedure TNonBlockingProtocolProcessor.process(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const streamId : IStreamId
    );
    var id : shortString;
        buff : PBuffInfo;
    begin
        id := streamId.getId();
        buff := fBuffLists.find(id);
        if (buff = nil) then
        begin
            new(buff);
            buff^.id := id;
            buff^.buffer := TStreamAdapter.create(TMemoryStream.create());
            fBuffLists.add(id, buff);
        end;

        nonBlockingCopyStream(stream, buff, streamCloser, streamId);
        processBuffer(buff, stream, streamCloser, streamId);
    end;

    (*!------------------------------------------------
     * get StdIn stream for complete request
     *-----------------------------------------------*)
    function TNonBlockingProtocolProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fActualProcessor.getStdIn();
    end;

    (*!------------------------------------------------
     * set listener to be notified when request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TNonBlockingProtocolProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        fActualProcessor.setReadyListener(listener);
        result := self;
    end;

end.
