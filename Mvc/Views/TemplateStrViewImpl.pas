{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit TemplateStrViewImpl;

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
     * View that can render from a HTML template in
     * pascal variable/const/resource string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TTemplateStrFileView = class(TTemplateView)
    protected

        (*!------------------------------------------------
         * Build template
         *-------------------------------------------------
         * @return HTML template
         *-------------------------------------------------*)
        function buildTemplateStr(): string; virtual; abstract;

    public
        constructor create(
            const hdrs : IHeaders;
            const outputBufferInst : IOutputBuffer;
            const templateParserInst : ITemplateParser
        );
    end;

implementation

    constructor TTemplateStrFileView.create(
        const hdrs : IHeaders;
        const outputBufferInst : IOutputBuffer;
        const templateParserInst : ITemplateParser
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
