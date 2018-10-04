unit RegexIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to replace string
     using regex
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRegex = interface
        ['{E08AD12B-C606-48FF-A9FA-728EAB14AB35}']
        function replace(
            const regex : string;
            const source : string;
            const replacement : string
        ) : string;
    end;

implementation
end.
