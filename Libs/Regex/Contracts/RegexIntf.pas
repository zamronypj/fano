{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RegexIntf;

interface

{$H+}

type
    TRegexMatches = array of array of string;
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
