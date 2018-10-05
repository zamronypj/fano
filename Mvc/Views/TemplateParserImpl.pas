unit TemplateParserImpl;

interface

uses
    ViewParamsIntf,
    TemplateParserIntf,
    RegexIntf;

type
    {------------------------------------------------
     basic class that can parse template and replace
     variable placeholder with value
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateParser = class(TInterfacedObject, ITemplateParser)
    private
        regex : IRegex;
        openTag: string;
        closeTag : string;
    public
        constructor create(
            const regexInst : IRegex;
            const openTagStr : string;
            const closeTagStr : string
        );
        destructor destroy(); override;
        function parse(
            const templateStr : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation

uses
    classes;

    constructor TTemplateParser.create(
        const regexInst : IRegex;
        const openTagStr : string;
        const closeTagStr : string
    );
    begin
        regex := regexInst;
        openTag := regex.quote(openTagStr);
        closeTag := regex.quote(closeTagStr);
    end;

    destructor TTemplateParser.destroy();
    begin
        inherited destroy();
        regex := nil;
    end;

    function TTemplateParser.parse(
        const templateStr : string;
        const viewParams : IViewParameters
    ) : string;
    var keys : TStrings;
        i:integer;
        pattern, valueData, replacedStr : string;
    begin
        replacedStr := templateStr;
        keys := viewParams.vars();
        for i := 0 to keys.count-1 do
        begin
            //if openTag is {{ and closeTag is }} then we
            //build pattern such as \{\{\s*variableName\s*\}\}
            pattern := openTag + '\s*' + keys[i] + '\s*' + closeTag;
            valueData := viewParams.getVar(keys[i]);
            replacedStr := regex.replace(pattern, replacedStr, valueData);
        end;
        result:= replacedStr;
    end;
end.
