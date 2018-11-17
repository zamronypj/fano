{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ViewPartialImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    ViewParametersIntf,
    ViewPartialIntf,
    TemplateParserIntf;

type

    (*!------------------------------------------------
     * View that can render from a HTML template to string
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TViewPartial = class(TInterfacedObject, IViewPartial, IDependency)
    private
        templateParser : ITemplateParser;
    private
        function readFileToString(const templatePath : string) : string;
    public
        constructor create(const templateParserInst : ITemplateParser);
        destructor destroy(); override;

        function partial(
            const templatePath : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation

uses
    classes,
    sysutils;

    constructor TViewPartial.create(const templateParserInst : ITemplateParser);
    begin
        templateParser := templateParserInst;
    end;

    destructor TViewPartial.destroy();
    begin
        inherited destroy();
        templateParser := nil;
    end;

    function TViewPartial.readFileToString(const templatePath : string) : string;
    var fstream : TFileStream;
        len : int64;
    begin
        //open for read and share but deny write
        //so if multiple processes of our application access same file
        //at the same time they stil can open and read it
        fstream := TFileStream.create(templatePath, fmOpenRead or fmShareDenyWrite);
        try
            len := fstream.size;
            setLength(result, len);
            //pascal string start from index 1
            fstream.read(result[1], len);
        finally
            fstream.free();
        end;
    end;

    function TViewPartial.partial(
        const templatePath : string;
        const viewParams : IViewParameters
    ) : string;
    begin
        result := templateParser.parse(
            readFileToString(templatePath),
            viewParams
        );
    end;

end.
