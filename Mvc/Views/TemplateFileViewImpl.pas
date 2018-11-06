{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit TemplateFileViewImpl;

interface

{$MODE OBJFPC}
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

    (*!------------------------------------------------
     * View that can render from a HTML template file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TTemplateFileView = class(TTemplateView)
    public
        constructor create(
            const hdrs : IHeaders;
            const outputBufferInst : IOutputBuffer;
            const templateParserInst : ITemplateParser;
            const templatePath : string
        ); override;
    end;

implementation

    constructor TTemplateFileView.create(
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
            readFileToString(templatePath)
        );
    end;

end.
