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
    classes,
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
                result.matches[0] := re.match[1];
            end;
        finally
            re.free();
        end;
    end;

    function TRegex.greedyMatch(
        const regexPattern : string;
        const source : string
    ) : TRegexMatchResult;
    const MAX_ELEMENT = 1000;
    var re : TRegExpr;
        actualElement : integer;
    begin
        re := TRegExpr.create(regexPattern);
        try
            //assume no match
            setLength(result.matches, 0);
            result.matched := re.exec(source);
            if (result.matched) then
            begin
                //pre-allocated element, to avoid frequent
                //memory allocation/deallocation
                setLength(result.matches, MAX_ELEMENT);
                actualElement := 1;
                result.matches[0] := re.match[1];
                while (re.execNext()) do
                begin
                    if (actualElement < MAX_ELEMENT) then
                    begin
                        result.matches[actualElement] := re.match[1];
                    end else
                    begin
                        //grow array
                        setLength(
                            result.matches,
                            length(result.matches) + MAX_ELEMENT
                        );
                    end;
                    inc(actualElement);
                end;
                //truncate array to number of actual element
                setLength(result.matches, actualElement);
            end;
        finally
            re.free();
        end;
    end;
end.
