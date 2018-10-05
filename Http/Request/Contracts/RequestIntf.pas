unit RequestIntf;

interface
{$H+}

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP request
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequest = interface
        ['{32913245-599A-4BF4-B25D-7E2EF349F7BB}']
        function getQueryParam(const key: string) : string;
        function getCookieParam(const key: string) : string;
    end;

implementation
end.
