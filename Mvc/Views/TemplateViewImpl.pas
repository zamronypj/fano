{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit TemplateViewImpl;

interface

{$H+}

uses
    ResponseIntf,
    ViewParametersIntf,
    ViewIntf,
    TemplateFetcherIntf,
    TemplateParserIntf,
    OutputBufferIntf,
    CloneableIntf;

type
    {------------------------------------------------
     View that can render from a HTML template string
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateView = class(TInterfacedObject, ICloneable, IView, IResponse, ITemplateFetcher)
    private
        templateContent : string;
        outputBuffer : IOutputBuffer;
        templateParser : ITemplateParser;
        function readFileToString(const templatePath : string) : string;
    public
        constructor create(
            const outputBufferInst : IOutputBuffer;
            const templateParserInst : ITemplateParser;
            const templateSrc : string
        ); virtual;
        destructor destroy(); override;

        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;

        function write() : IResponse;

        function fetch(
            const templatePath : string;
            const viewParams : IViewParameters
        ) : string;

        function clone() : ICloneable;
    end;

implementation

uses
    classes,
    sysutils;

    constructor TTemplateView.create(
        const outputBufferInst : IOutputBuffer;
        const templateParserInst : ITemplateParser;
        const templateSrc : string
    );
    begin
        outputBuffer := outputBufferInst;
        templateParser := templateParserInst;
        templateContent := templateSrc;
    end;

    destructor TTemplateView.destroy();
    begin
        inherited destroy();
        outputBuffer := nil;
        templateParser := nil;
    end;

    function TTemplateView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    begin
        outputBuffer.beginBuffering();
        try
            writeln('Content-Type: text/html');
            writeln();
            writeln(templateParser.parse(templateContent, viewParams));
        finally
            outputBuffer.endBuffering();
        end;
        result := self;
    end;

    function TTemplateView.write() : IResponse;
    begin
        writeln(outputBuffer.flush());
        result := self;
    end;

    function TTemplateView.readFileToString(const templatePath : string) : string;
    var fstream : TFileStream;
        str : TStringStream;
    begin
        fstream := TFileStream.create(templatePath, fmOpenRead);
        str := TStringStream.create('');
        try
            str.copyFrom(fstream, 0);
            result := str.dataString;
        finally
            fstream.free();
            str.free();
        end;
    end;

    function TTemplateView.fetch(
        const templatePath : string;
        const viewParams : IViewParameters
    ) : string;
    var content :string;
    begin
        try
            content := readFileToString(templatePath);
            result := templateParser.parse(content, viewParams);
        except
            on e : Exception do
            begin
                writeln('Read ' + e.message);
            end;
        end;
    end;

    function TTemplateView.clone() : ICloneable;
    var clonedObj : TTemplateView;
    begin
        clonedObj := TTemplateView.create(
            outputBuffer,
            templateParser,
            templateContent
        );
        //TODO : copy any property
        result := clonedObj;
    end;
end.
