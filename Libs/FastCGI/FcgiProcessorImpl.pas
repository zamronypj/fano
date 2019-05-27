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

        procedure clearEnvironments();
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
        function process(const stream : IStreamAdapter;) : boolean;

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

    fastcgi;

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
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TFcgiProcessor.destroy();
    begin
        inherited destroy();
        fcgiParser := nil;
        clearEnvironments();
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
     * @param stream socket stream
     * @return boolean true when FCGI_PARAMS and FCGI_STDIN
     *         stream is complete otherwise false
     *-----------------------------------------------*)
    function TFcgiProcessor.process(const stream : IStreamAdapter) : boolean;
    var arecord : IFcgiRecord;
        complete : boolean;
    begin
        complete := false;
        if (fcgiParser.hasFrame(stream)) then
        begin
            arecord := fcgiParser.parseFrame(stream);

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
                fcgiEnvironment[fcgiRequestId] := TFcgiEnvironment.create(arecord);
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
