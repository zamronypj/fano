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

    ResponseIntf,
    ViewParametersIntf,
    ViewIntf,
    TemplateParserIntf,
    CloneableIntf,
    ViewPartialIntf;

type

    (*!------------------------------------------------
     * View that can render from a HTML template string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TView = class(TInterfacedObject, ICloneable, IView, IViewPartial, IResponse)
    private
        responseInst : IResponse;
        partialInst : IViewPartial;
        templateContent : string;
        templateParser : ITemplateParser;
    public
        constructor create(
            const respInst : IResponse;
            const partInst : IViewPartial;
            const templateParserInst : ITemplateParser;
            const templateSrc : string
        );

        destructor destroy(); override;

        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;


        function clone() : ICloneable;

        //delegate IResponse implementation to external class
        property response : IResponse read responseInst implements IResponse;

        //delegate IViewPartial to external class
        property partial : IViewPartial read partialInst implements IViewPartial;
    end;

implementation

uses
    sysutils,

    ResponseStreamIntf;

    constructor TView.create(
        const respInst : IResponse;
        const partInst : IViewPartial;
        const templateParserInst : ITemplateParser;
        const templateSrc : string
    );
    begin
        responseInst := respInst;
        partialInst := partInst;
        templateParser := templateParserInst;
        templateContent := templateSrc;
    end;

    destructor TView.destroy();
    begin
        inherited destroy();
        responseInst := nil;
        partialInst := nil;
        templateParser := nil;
    end;

    function TView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    var bodyInst : IResponseStream;
        contentLength : string;
    begin
        bodyInst := responseInst.body();
        bodyInst.write(templateParser.parse(templateContent, viewParams));
        contentLength := intToStr(bodyInst.size());
        responseInst.headers().setHeader('Content-Length',  contentLength);
        result := self;
    end;

    function TView.clone() : ICloneable;
    begin
        result := TView.create(
            responseInst.clone() as IResponse,
            partialInst,
            templateParser,
            templateContent
        );
    end;
end.
