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

        //store request id that is complete
        fcgiRequestId : word;

        fTmpBuffer : TMemoryStream;

        procedure copySocketStreamToTmpStream(
            const stream : IStreamAdapter;
            const tmpBuffer : TMemoryStream
        );
        function processBuffer(const buffer : pointer; const bufferSize : int64; out totRead : int64) : boolean;
        function discardProcessedData(const tmp : TStream; const bytesToDiscard : int64) : TMemoryStream;
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
        function process(const stream : IStreamAdapter) : boolean;

        (*!------------------------------------------------
         * get current environment
         *-----------------------------------------------
         * @return environment
         *-----------------------------------------------*)
        function getEnvironment() : ICGIEnvironment;

        (*!------------------------------------------------
         * get current FCGI_STDIN complete stream
         *-----------------------------------------------
         * @return stream
         *-----------------------------------------------*)
        function getStdInStream() : IStreamAdapter;

        (*!------------------------------------------------
         * get request id that is complete
         *-----------------------------------------------
         * @return request id
         *-----------------------------------------------*)
        function getRequestId() : word;
    end;

implementation

uses

    fastcgi,
    sysutils,
    math,
    FcgiEnvironmentImpl,
    FcgiRecordIntf,
    KeyValuePairIntf,
    EnvironmentFactoryIntf,
    EInvalidFcgiRequestIdImpl;

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
        fcgiRequestId := 0;
        fTmpBuffer := TMemoryStream.create();
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiProcessor.destroy();
    begin
        inherited destroy();
        fcgiParser := nil;
        fcgiRequestMgr := nil;
        freeAndNil(fTmpBuffer);
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param buffer, buffer where data from socket is stored
     * @param bufferSize, size of buffer where data from socket is stored
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    function TFcgiProcessor.processBuffer(const buffer : pointer; const bufferSize : int64; out totRead : int64) : boolean;
    var arecord : IFcgiRecord;
        complete : boolean;
    begin
        complete := false;
        totRead := 0;
        if (fcgiParser.hasFrame(buffer, bufferSize)) then
        begin
            arecord := fcgiParser.parseFrame(buffer, bufferSize);
            totRead := arecord.getRecordSize();
            complete := fcgiRequestMgr.add(arecord).complete(arecord.getRequestId());
            if (complete) then
            begin
                //request is complete, keep track last request id that is complete
                fcgiRequestId := arecord.getRequestId();
                //TODO : initialize POST-ed for this request
            end;
        end;

        result := complete;
    end;

    function TFcgiProcessor.discardProcessedData(const tmp : TStream; const bytesToDiscard : int64) : TMemoryStream;
    var tmpReadBuffer : TMemoryStream;
    begin
        //discard processed buffer
        tmpReadBuffer := TMemoryStream.create();
        try
            tmp.seek(bytesToDiscard, soFromBeginning);
            tmpReadBuffer.copyFrom(tmp, tmp.size - bytesToDiscard);
        finally
            tmp.free();
            result := tmpReadBuffer;
        end;
    end;

    procedure TFcgiProcessor.copySocketStreamToTmpStream(
        const stream : IStreamAdapter;
        const tmpBuffer : TMemoryStream
    );
    const MAX_TMP_SIZE = 4096;
    var tmp : pointer;
        bytesRead : int64;
    begin
        //stream will come from socket connection,
        //so we do not know its size, just allocate big enough
        //and read bit by bit until exhausted
        getMem(tmp, MAX_TMP_SIZE);
        try
            repeat
                bytesRead := stream.read(tmp^, MAX_TMP_SIZE);
                if bytesRead > 0 then
                begin
                    tmpBuffer.writeBuffer(tmp^, bytesRead);
                end
            until bytesRead <= 0;
            //bytesRead < 0 means socket read error
        finally
            freeMem(tmp, MAX_TMP_SIZE);
        end;
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param stream socket stream
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    function TFcgiProcessor.process(const stream : IStreamAdapter) : boolean;
    var totProcessed : int64;
    begin
        copySocketStreamToTmpStream(stream, fTmpBuffer);
        totProcessed := 0;
        result := processBuffer(fTmpBuffer.memory, fTmpBuffer.size, totProcessed);
        if (totProcessed > 0) then
        begin
            //TODO: maybe it is better to just advanced stream position
            //instead of discard which require copy?
            fTmpBuffer := discardProcessedData(fTmpBuffer, totProcessed);
        end;
    end;

    (*!------------------------------------------------
     * get current environment
     *-----------------------------------------------
     * @return environment
     *-----------------------------------------------*)
    function TFcgiProcessor.getEnvironment() : ICGIEnvironment;
    begin
        result := fcgiRequestMgr.getEnvironment(fcgiRequestId);
    end;

    (*!------------------------------------------------
     * get current FCGI_STDIN complete stream
     *-----------------------------------------------
     * @return stream
     *-----------------------------------------------*)
    function TFcgiProcessor.getStdInStream() : IStreamAdapter;
    begin
        result := fcgiRequestMgr.getStdInStream(fcgiRequestId);
    end;

    (*!------------------------------------------------
     * get request id that is complete
     *-----------------------------------------------
     * @return request id
     *-----------------------------------------------*)
    function TFcgiProcessor.getRequestId() : word;
    begin
        result := fcgiRequestId;
    end;

end.
