unit RegexIntf;

interface

{$H+}

type
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
    end;

implementation
end.
