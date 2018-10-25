{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit SimpleTemplateParserImpl;

interface

{$H+}

uses
    DependencyIntf,
    ViewParametersIntf,
    TemplateParserIntf;

type
    {------------------------------------------------
     basic class that can parse template and replace
     variable placeholder with value
     This should be faster than TTemplateParser because
     it does not use regular expression and just plain string replace
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TSimpleTemplateParser = class(TInterfacedObject, ITemplateParser, IDependency)
    private
        openTag: string;
        closeTag : string;
    public
        constructor create(
            const openTagStr : string;
            const closeTagStr : string
        );

        (*!---------------------------------------------------
         * replace template content with view parameters
         * ----------------------------------------------------
         * @param templateStr string contain content of template
         * @param viewParams view parameters instance
         * @return replaced content
         *-----------------------------------------------------*)
        function parse(
            const templateStr : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation

uses

    sysutils,
    classes;

    constructor TSimpleTemplateParser.create(
        const openTagStr : string;
        const closeTagStr : string
    );
    begin
        openTag := openTagStr;
        closeTag := closeTagStr;
    end;

    (*!---------------------------------------------------
     * replace template content with view parameters
     * ----------------------------------------------------
     * @param templateStr string contain content of template
     * @param viewParams view parameters instance
     * @return replaced content
     * ----------------------------------------------------
     * if opentag='{{' and close tag='}}'' and view parameters
     * contain key='name' with value='joko'
     * then for template content 'hello {{name}}'
     * output will be  'hello joko'
     * This will replace exact same pattern so
     * {{ name }} is not same as {{name}}
     *-----------------------------------------------------*)
    function TSimpleTemplateParser.parse(
        const templateStr : string;
        const viewParams : IViewParameters
    ) : string;
    var keys : TStrings;
        i:integer;
        pattern, valueData : string;
    begin
        result := templateStr;
        keys := viewParams.vars();
        for i := 0 to keys.count-1 do
        begin
            //if openTag is {{ and closeTag is }} then we
            //build pattern such as {{variableName}}
            pattern := openTag + keys[i] + closeTag;
            valueData := viewParams.getVar(keys[i]);
            result := stringReplace(result, pattern, valueData, [rfReplaceAll]);
        end;
    end;
end.
