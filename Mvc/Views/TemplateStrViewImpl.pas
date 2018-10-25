{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit TemplateStrViewImpl;

interface

{$H+}

uses
    HeadersIntf,
    ResponseIntf,
    ViewParametersIntf,
    ViewIntf,
    OutputBufferIntf,
    TemplateViewImpl,
    TemplateParserIntf;

type
    {------------------------------------------------
     View that can render from a HTML template in
     pascal variable/const/resource string

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateStrFileView = class(TTemplateView)
    protected
        function buildTemplateStr(): string; virtual; abstract;
    public
        constructor create(
            const hdrs : IHeaders;
            const outputBufferInst : IOutputBuffer;
            const templateParserInst : ITemplateParser;
            const templatePath : string
        ); override;
    end;

implementation

    constructor TTemplateStrFileView.create(
        const hdrs : IHeaders;
        const outputBufferInst : IOutputBuffer;
        const templateParserInst : ITemplateParser;
        const templatePath : string
    );
    begin
        inherited create(
            hdrs,
            outputBufferInst,
            templateParserInst,
            buildTemplateStr()
        );
    end;

end.
