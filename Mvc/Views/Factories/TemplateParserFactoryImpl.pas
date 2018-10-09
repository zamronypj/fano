unit TemplateParserFactoryImpl;

interface
{$H+}

uses
    DependencyIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     basic class that can create template parser
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateParserFactory = class(TFactory, IDependencyFactory)
    private
        openTag : string;
        closeTag : string;
    public
        constructor create(
            const openTagStr : string = '{{';
            const closeTagStr : string = '}}'
        );
        function build() : IDependency; override;
    end;

implementation

uses
    TemplateParserImpl,
    RegexImpl;

    constructor TTemplateParserFactory.create(
        const openTagStr : string = '{{';
        const closeTagStr : string = '}}'
    );
    begin
        openTag := openTagStr;
        closeTag := closeTagStr;
    end;

    function TTemplateParserFactory.build() : IDependency;
    begin
        //replace any variable {{ variableName }} with value
        result := TTemplateParser.create(
            TRegex.create(),
            openTag,
            closeTag
        );
    end;
end.
