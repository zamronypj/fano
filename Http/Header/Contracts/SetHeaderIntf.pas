unit SetHeaderIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     set HTTP header
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    ISetHeaderInterface = interface
        ['{F843B30E-EC21-4193-98B9-C2F56062D398}']
        function setValue(const headerValue : string) : ISetHeaderInterface;
    end;

implementation
end.
