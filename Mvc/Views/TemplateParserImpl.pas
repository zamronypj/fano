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
            const openTagStr;
            const closeTagStr : string
        );
        destructor destroy(); override;
        function parse(
            const templateStr : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation

    constructor TTemplateParser.create(
        const regexInst : IRegex;
        const openTagStr;
        const closeTagStr : string
    );
    begin
        regex := regexInst;
        openTag := openTagStr;
        closeTag := closeTagStr;
    end;

    destructor destroy();
    begin
        inherited destroy();
        regex := nil;
    end;

    function TTemplateParser.parse(
        const templateStr : string;
        const viewParams : IViewParameters
    ) : string;
    begin

    end;
end.
