unit RegexImpl;

interface

{$H+}

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

        function match(
            const regexPattern : string;
            const source : string
        ) : TRegexMatchResult;

        function greedyMatch(
            const regexPattern : string;
            const source : string
        ) : TRegexMatchResult;
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

    function TRegex.match(
        const regexPattern : string;
        const source : string
    ) : TRegexMatchResult;
    var re : TRegExpr;
    begin
        re := TRegExpr.create(regexPattern);
        try
            setLength(result.matches, 0);
            result.matched := re.exec(source);
            if (result.matched) then
            begin
                setlength(result.matches, 1);
                result.matches[0] = re.match[1];
            end;
        finally
            re.free();
        end;
    end;

    function TRegex.greedyMatch(
        const regexPattern : string;
        const source : string
    ) : TRegexMatchResult;
    const INITIAL_CAPACITY = 20;
    var re : TRegExpr;
        matches : TStringList;
        i, len : integer;
    begin
        re := TRegExpr.create(regexPattern);
        matches := TStringList.create(INITIAL_CAPACITY);
        try
            setLength(result.matches, 0);
            result.matched := re.exec(source);
            if (result.matched) then
            begin
                matches.add(re.match[1]);
                while (re.execNext()) do
                begin
                    matches.add(re.match[1]);
                end;

                len := matches.count;
                setlength(result.matches, len);
                for i := 0 to len-1 do
                begin
                    result.matches[i] := matches[i];
                end;
            end;
        finally
            re.free();
            matches.free();
        end;
    end;
end;