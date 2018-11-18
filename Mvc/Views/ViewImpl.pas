{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ViewImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    ResponseIntf,
    ViewParametersIntf,
    ViewIntf,
    TemplateParserIntf;

type

    (*!------------------------------------------------
     * View that can render from a HTML template string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TView = class(TInterfacedObject, IView, IDependency)
    private
        templateContent : string;
        templateParser : ITemplateParser;
    public
        constructor create(
            const templateParserInst : ITemplateParser;
            const tplContent : string
        );

        destructor destroy(); override;

        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;

    end;

implementation

uses

    SysUtils,
    ResponseStreamIntf;

    constructor TView.create(
        const templateParserInst : ITemplateParser;
        const tplContent : string
    );
    begin
        templateParser := templateParserInst;
        templateContent := tplContent;
    end;

    destructor TView.destroy();
    begin
        inherited destroy();
        templateParser := nil;
    end;

    function TView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    var bodyInst : IResponseStream;
        contentLength : string;
    begin
        bodyInst := response.body();
        bodyInst.write(templateParser.parse(templateContent, viewParams));
        contentLength := intToStr(bodyInst.size());
        response.headers().setHeader('Content-Length',  contentLength);
        result := response;
    end;
end.
