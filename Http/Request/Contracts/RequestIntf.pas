unit RequestIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP request
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRequest = interface
        function getQueryParam(const key: string) : string;
    end;

implementation
end.
