unit RegexIntf;

interface

{$H+}

type
    TRegexMatches = array of string;
    TRegexMatchResult = record
        matched : boolean;
        matches : TRegexMatches;
    end;

    {------------------------------------------------
     interface for any class having capability to replace string
     using regex
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRegex = interface
        ['{E08AD12B-C606-48FF-A9FA-728EAB14AB35}']
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
end.
