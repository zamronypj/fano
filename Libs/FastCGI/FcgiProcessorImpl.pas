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
    EnvironmentIntf,
    StreamAdapterIntf,
    FcgiProcessorIntf,
    FcgiRequestManagerIntf,
    FcgiRequestIdAwareIntf,
    FcgiRequestReadyListenerIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment and write response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiProcessor = class(TInterfacedObject, IFcgiProcessor, IFcgiRequestIdAware)
    private
        fcgiParser : IFcgiFrameParser;
        fcgiRequestMgr : IFcgiRequestManager;
        fcgiRequestReadyListener : IFcgiRequestReadyListener;

        function processBuffer(const buffer : pointer; const bufferSize : int64; out totRead : int64) : boolean;
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

        destructor destroy(); override;

        (*!------------------------------------------------
         * process request stream
         *-----------------------------------------------
         * @return true if all data from web server is ready to
         * be handle by application (i.e, environment, STDIN already parsed)
         *-----------------------------------------------*)
        procedure process(const stream : IStreamAdapter);

        (*!------------------------------------------------
         * set listener to be notified weh request is ready
         *-----------------------------------------------
         * @return current instance
         *-----------------------------------------------*)
        function setReadyListener(const listener : IFcgiRequestReadyListener) : IFcgiProcessor;
    end;

implementation

uses

    fastcgi,
    sysutils,
    FcgiEnvironmentImpl,
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
        inherited destroy();
        fcgiParser := nil;
        fcgiRequestMgr := nil;
        fcgiRequestReadyListener := nil;
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param buffer, buffer where data from socket is stored
     * @param bufferSize, size of buffer where data from socket is stored
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    function TFcgiProcessor.processBuffer(const buffer : pointer; const bufferSize : int64) : boolean;
    var afcgiRec : IFcgiRecord;
        requestId : word;
        handled : boolean;
    begin
        result := false;
        if (fcgiParser.hasFrame(buffer, bufferSize)) then
        begin
            afcgiRec := fcgiParser.parseFrame(buffer, bufferSize);
            fcgiRequestMgr.add(afcgiRec);
            requestId := afcgiRec.getRequestId();
            if fcgiRequestMgr.complete(requestId) then
            begin
                if assigned(fcgiRequestReadyListener) then
                begin
                    handled := fcgiRequestReadyListener.ready(
                        fcgiRequestMgr.getEnvironment(requestId),
                        fcgiRequestMgr.getStdInStream(requestId)
                    );
                    if handled then
                    begin
                        fcgiRequestMgr.remove(requestId);
                    end;
                end;
            end;
        end;
    end;

    (*!-----------------------------------------------
     * process stream and parse for FCGI records until stream
     * is exhausted
     *------------------------------------------------
     * @param stream socket stream
     *-----------------------------------------------*)
    procedure TFcgiProcessor.process(const stream : IStreamAdapter);
    var bufPtr : pointer;
        bufSize  : integer;
        streamEmpty : boolean;
    begin
        repeat
            streamEmpty := fcgiParser.readRecord(stream, bufPtr, bufSize);
            if (bufPtr <> nil) and (bufSize > 0) then
            begin
                processBuffer(bufPtr, bufSize);
            end;
        until streamEmpty;
    end;

    (*!------------------------------------------------
     * set listener to be notified weh request is ready
     *-----------------------------------------------
     * @return current instance
     *-----------------------------------------------*)
    function setReadyListener(const listener : IFcgiRequestReadyListener) : IFcgiProcessor;
    begin
        fcgiRequestReadyListener := listener;
        result := self;
    end;

end.
