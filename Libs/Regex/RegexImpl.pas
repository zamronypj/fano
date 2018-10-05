unit RegexImpl;

interface

uses
    RegexIntf;

type
    {------------------------------------------------
     basic class having capability to replace string
     using regex
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRegex = class(TInterfacedObject, IRegex)
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

    function TRegex.replace(
        const regexPattern : string;
        const source : string;
        const replacement : string
    ) : string;
    begin
        result := ReplaceRegExpr(
            regexPattern,
            source,
            replacement,
            true
        );
    end;

    function TRegex.quote(const regexPattern : string) : string;
    begin
        result := QuoteRegExprMetaChars(regexPattern);
    end;
end.
