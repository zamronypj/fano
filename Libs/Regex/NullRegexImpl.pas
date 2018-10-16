{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

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

    function TNullRegex.match(
        const regexPattern : string;
        const source : string
    ) : TRegexMatchResult;
    begin
        result.matched := false;
        setLength(result.matches, 0);
    end;

    function TNullRegex.greedyMatch(
        const regexPattern : string;
        const source : string
    ) : TRegexMatchResult;
    begin
        result.matched := false;
        setLength(result.matches, 0);
    end;
end.
