unit ResponseIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IResponse = interface
        function write() : IResponse;
    end;

implementation
end.
