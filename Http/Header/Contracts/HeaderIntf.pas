unit HeaderIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     write HTTP header
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IHeaderInterface = interface
        ['{B1AA76AC-54A7-4D4E-B309-B19DF7257823}']
        function writeHeader() : IHeaderInterface;
    end;

implementation
end.
