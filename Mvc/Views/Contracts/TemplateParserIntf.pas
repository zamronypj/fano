unit TemplateParserIntf;

interface
{$H+}

uses
    ViewParametersIntf;

type
    {------------------------------------------------
     interface for any class having capability parse
     template and replace variable placeholder with value
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    ITemplateParser = interface
        ['{06146BC7-5543-4FD1-956C-9FC47122EC70}']
        function parse(
            const templateStr : string;
            const viewParams : IViewParameters
        ) : string;
    end;

implementation
end.
