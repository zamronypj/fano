unit ResponseIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IResponse = interface
        ['{36D6274C-3EE1-4262-BACB-2A313C673206}']
        function write() : IResponse;
    end;

implementation
end.
