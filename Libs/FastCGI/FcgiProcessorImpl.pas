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

    EnvironmentIntf,
    StreamAdapterIntf,
    FcgiProcessorIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI frame processor that parse FastCGI frame
     * and build CGI environment and write response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiProcessor = class(TInterfacedObject, IFcgiProcessor)
    private
        fcgiParser : IFcgiFrameParser;
        fcgiEnvironments : array of ICGIEnvironment;

        fcgiRequestId : word;

        //store FCGI_STDIN stream completeness
        fcgiStdInComplete : boolean;
        //store FCGI_PARAMS stream completeness
        fcgiParamsComplete : boolean;

        tmpBuffer : TMemoryStream;

        procedure clearEnvironments();
        function processBuffer(const buffer; const bufferSize : int64; out totRead : int64) : boolean;
        function discardReadData(const tmp : TStream; const bytesToDiscard : int64) : TStream
    public
        (*!-----------------------------------------------
         * constructor
         *------------------------------------------------
         * @param parser FastCGI frame parser
         *-----------------------------------------------*)
        constructor create(const parser : IFcgiFrameParser);
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
        * write string to FCGI_STDOUT stream and
        * mark it end of request
        *-----------------------------------------------
        * @return current instance
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter; const str : string)  : IFcgiProcessor;
    end;

implementation

uses

    fastcgi,
    classes,
    KeyValuePairIntf;

    (*!-----------------------------------------------
     * constructor
     *------------------------------------------------
     * @param parser FastCGI frame parser
     *-----------------------------------------------*)
    constructor TFcgiProcessor.create(const parser : IFcgiFrameParser);
    begin
        inherited create();
        fcgiParser := parser;
        setLength(fcgiEnvironments, 10);
        fcgiRequestId := 0;
        fcgiStdInComplete := false;
        fcgiParamsComplete := false;
        tmpBuffer := TMemoryStream.create();
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiProcessor.destroy();
    begin
        inherited destroy();
        fcgiParser := nil;
        clearEnvironments();
        freeAndNil(tmpBuffer);
    end;

    (*!-----------------------------------------------
     * clear all CGI environments
     *-----------------------------------------------*)
    procedure TFcgiProcessor.clearEnvironments();
    var i : integer;
    begin
        for i := 0 to length(fcgiEnvironments)-1 do
        begin
            fcgiEnvironments[i] := nil;
        end;
        setLength(fcgiEnvironments, 0);
        fcgiEnvironments := nil;
    end;

    (*!-----------------------------------------------
     * parse stream for FCGI records
     *------------------------------------------------
     * @param buffer, buffer where data from socket is stored
     * @param bufferSize, size of buffer where data from socket is stored
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    function TFcgiProcessor.processBuffer(const buffer; const bufferSize : int64; out totRead : int64) : boolean;
    var arecord : IFcgiRecord;
        complete : boolean;
    begin
        complete := false;
        totRead := 0;
        if (fcgiParser.hasFrame(buffer, bufferSize)) then
        begin
            arecord := fcgiParser.parseFrame(buffer, bufferSize);
            totRead := arecord.getRecordSize();
            //if we received FCGI_PARAMS with empty data, it means web server complete
            //sending FCGI_PARAMS request data.
            if (arecord.getType() = FCGI_BEGIN_REQUEST) then
            begin
                fcgiRequestId := arecord.getRequestId();
            end;

            //if we received FCGI_PARAMS with empty data, it means web server complete
            //sending FCGI_PARAMS request data.
            if (arecord.getType() = FCGI_PARAMS) and (arecord.getContentLength() = 0) then
            begin
                fcgiParamsComplete := true;

                //TODO: need to rethink when FCGI_PARAMS record sent multiple
                //times. Need wrapper class that implements IKeyValuePair and wraps
                //multiple FcgiParams records as one big IKeyValuePair
                fcgiEnvironments[fcgiRequestId] := TFcgiEnvironment.create(arecord as IKeyValuePair);
            end;

            //if we received FCGI_STDIN with empty data, it means web server complete
            //sending FCGI_STDIN request data.
            if (arecord.getType() = FCGI_STDIN) and (arecord.getContentLength() = 0) then
            begin
                fcgiStdInComplete := true;
                //TODO: read POST data to Request
            end;

            complete := fcgiParamsComplete and fcgiStdInComplete;

            if (complete) then
            begin
                //request is complete, reset status for next loop
                fcgiParamsComplete := false;
                fcgiStdInComplete := false;
            end;
        end;

        result := complete;
    end;

    function TFcgiProcessor.discardReadData(const tmp : TStream; const bytesToDiscard : int64) : TStream
    var tmpReadBuffer : TMemoryStream;
        sizeToCopy : int64;
    begin
        //discard read buffer
        tmpReadBuffer := TMemoryStream.create();
        try
            tmp.seek(bytesToDiscard, soFromBeginning);
            tmpReadBuffer.copyFrom(tmp, tmp.size - bytesToDiscard);
        finally
            tmp.free();
            result := tmpReadBuffer;
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
    var tmp : pointer;
        tmpSize, totRead : int64;
        tmpReadBuffer : TMemoryStream;
    begin
        tmpSize := stream.size();
        getMem(tmp, tmpSize);
        try
            stream.readBuffer(tmp^, tmpSize);
            tmpBuffer.writeBuffer(tmp^, tmpSize);
            result := processBuffer(tmpBuffer.memory, tmpBuffer.size, totRead);
            if (totRead > 0) then
            begin
                tmpBuffer := discardReadData(tmpBuffer, totRead);
            end;
        finally
            freeMem(tmp, tmpSize);
        end;
    end;

    (*!------------------------------------------------
    * get current environment
    *-----------------------------------------------
    * @return environment
    *-----------------------------------------------*)
    function TFcgiProcessor.getEnvironment() : ICGIEnvironment;
    begin
        //TODO throws exception when fcgiEnvironment is nil
        result := fcgiEnvironments[fcgiRequestId];
    end;

    (*!------------------------------------------------
    * write string to FCGI_STDOUT stream and
    * mark it end of request
    *-----------------------------------------------
    * @return current instance
    *-----------------------------------------------*)
    function TFcgiProcessor.write(const stream : IStreamAdapter; const str : string)  : IFcgiProcessor;
    var arecord : IFcgiRecord;
    begin
        arecord := TFcgiStdOut.create(fcgiRequestId, str);
        arecord.write(stream);

        arecord := TFcgiEndRequest.create(fcgiRequestId);
        arecord.write(stream);
    end;

end.
