unit SetHeaderIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     set HTTP header
     @author Zamrony P. Juhara <zamrony@yahoo.com>
    -----------------------------------------------}
    ISetHeaderInterface = interface
        function setValue(const headerValue : string) : ISetHeaderInterface;
    end;

implementation
end.
