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

    FcgiProcessorIntf,
    FcgiFrameParserIntf;

type

    (*!-----------------------------------------------
     * FastCGI web application that implements IWebApplication
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiProcessor = class(TInterfacedObject, IFcgiProcessor)
    private
        fcgiParser : IFcgiFrameParser;
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
    end;

    destructor TFcgiProcessor.destroy();
    begin
        inherited destroy();
        fcgiParser := nil;
    end;

    function TFcgiProcessor.process(const stream : IStreamAdapter) : boolean;
    var arecord : IFcgiRecord;
        complete : boolean;
    begin
        complete := false;
        if (fcgiParser.hasFrame(stream)) then
        begin
            arecord := fcgiParser.parseFrame(stream);
            //if we received FCGI_STDIN with empty data, it means web server complete
            //sending request data.
            complete := (arecord.getType() = FCGI_STDIN) and (arecord.getContentLength() = 0);
        end;
        result := complete;
    end;

end.
