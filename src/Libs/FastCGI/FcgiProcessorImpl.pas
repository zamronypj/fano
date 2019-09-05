{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit FcgiProcessorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    CloseableIntf,
    EnvironmentIntf,
    StreamAdapterIntf,
    ProtocolProcessorIntf,
    ReadyListenerIntf,
    StdInStreamAwareIntf,
    FcgiRequestManagerIntf,
    FcgiRequestIdAwareIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiProcessor = class(TInterfacedObject, IProtocolProcessor, IFcgiRequestIdAware, IStdInStreamAware)
    private
        fcgiParser : IFcgiFrameParser;
        fcgiRequestMgr : IFcgiRequestManager;
        fcgiRequestReadyListener : IReadyListener;

        //store request id that is ready to be served
        fCompleteRequestId : word;

        procedure processBuffer(
            const stream : IStreamAdapter;
            const streamCloser : ICloseable;
            const buffer : pointer;
            const bufferSize : ptrUint
        );
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param parser FastCGI frame parser
         * @param requestMgr, instance of request manager
         *-----------------------------------------------*)
        constructor create(
            const parser : IFcgiFrameParser;
            const requestMgr : IFcgiRequestManager
        );

        (*!-----------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!-----------------------------------------------
         * process stream and parse for FCGI records until stream
         * is exhausted
         *------------------------------------------------
         * @param stream socket stream
         * @param streamClose, instance which can close stream
         *-----------------------------------------------*)
        procedure process(
            const stream : IStreamAdapter;
            const streamCloser : ICloseable
        );

        (*!------------------------------------------------
         * set listener to be notified weh request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IReadyListener) : IProtocolProcessor;

        (*!------------------------------------------------
         * get request id
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function getRequestId() : word;

        (*!------------------------------------------------
        * get FastCGI StdIn stream for complete request
        *-----------------------------------------------*)
        function getStdIn() : IStreamAdapter;
    end;

implementation

uses

    FcgiRecordIntf,
    KeyValuePairIntf,
    EnvironmentFactoryIntf,
    EInvalidFcgiRequestIdImpl,
    EInvalidFcgiHeaderLenImpl;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param parser FastCGI frame parser
     * @param requestMgr, instance of request manager
     *-----------------------------------------------*)
    constructor TFcgiProcessor.create(
        const parser : IFcgiFrameParser;
        const requestMgr : IFcgiRequestManager
    );
    begin
        inherited create();
        fcgiParser := parser;
        fcgiRequestMgr := requestMgr;
        fcgiRequestReadyListener := nil;
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiProcessor.destroy();
    begin
        fcgiParser := nil;
        fcgiRequestMgr := nil;
        fcgiRequestReadyListener := nil;
        inherited destroy();
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param stream socket stream
     * @param streamClose, instance which can close stream
     * @param buffer, buffer where data from socket is stored
     * @param bufferSize, size of buffer where data from socket is stored
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    procedure TFcgiProcessor.processBuffer(
        const stream : IStreamAdapter;
        const streamCloser : ICloseable;
        const buffer : pointer;
        const bufferSize : ptrUint
    );
    var afcgiRec : IFcgiRecord;
        requestId : word;
    begin
        if (fcgiParser.hasFrame(buffer, bufferSize)) then
        begin
            afcgiRec := fcgiParser.parseFrame(buffer, bufferSize);
            fcgiRequestMgr.add(afcgiRec);
            requestId := afcgiRec.getRequestId();
            if fcgiRequestMgr.complete(requestId) then
            begin
                fCompleteRequestId := requestId;

                if assigned(fcgiRequestReadyListener) then
                begin
                    fcgiRequestReadyListener.ready(
                        stream,
                        fcgiRequestMgr.getEnvironment(requestId),
                        fcgiRequestMgr.getStdInStream(requestId)
                    );
                end;

                if not fcgiRequestMgr.keepConnection(requestId) then
                begin
                    streamCloser.close();
                end;

                fcgiRequestMgr.remove(requestId);
            end;
        end;
    end;

    (*!-----------------------------------------------
     * process stream and parse for FCGI records until stream
     * is exhausted
     *------------------------------------------------
     * @param stream socket stream
     * @param streamClose, instance which can close stream
     *-----------------------------------------------*)
    procedure TFcgiProcessor.process(const stream : IStreamAdapter; const streamCloser : ICloseable);
    var bufPtr : pointer;
        bufSize  : ptrUint;
        streamEmpty : boolean;
    begin
        repeat
            streamEmpty := fcgiParser.readRecord(stream, bufPtr, bufSize);
            if (bufPtr <> nil) and (bufSize > 0) then
            begin
                processBuffer(stream, streamCloser, bufPtr, bufSize);
            end;
        until streamEmpty;
    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function TFcgiProcessor.setReadyListener(const listener : IReadyListener) : IProtocolProcessor;
    begin
        fcgiRequestReadyListener := listener;
        result := self;
    end;

    (*!------------------------------------------------
     * get request id
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiProcessor.getRequestId() : word;
    begin
        result := fCompleteRequestId;
    end;

    (*!------------------------------------------------
     * get FastCGI StdIn stream for complete request
     *-----------------------------------------------*)
    function TFcgiProcessor.getStdIn() : IStreamAdapter;
    begin
        result := fcgiRequestMgr.getStdInStream(fCompleteRequestId);
    end;
end.
