unit NullRegexImpl;

interface
{$H+}

uses
    RegexIntf;

type
    {------------------------------------------------
     regex class that does nothing
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TNullRegex = class(TInterfacedObject, IRegex)
    private
    public
        function replace(
            const regexPattern : string;
            const source : string;
            const replacement : string
        ) : string;

        function quote(const regexPattern : string) : string;
    end;

implementation

uses
    regexpr;

    function TNullRegex.replace(
        const regexPattern : string;
        const source : string;
        const replacement : string
    ) : string;
    begin
        result := source;
    end;

    function TNullRegex.quote(const regexPattern : string) : string;
    begin
        result := QuoteRegExprMetaChars(regexPattern);
    end;
end.
