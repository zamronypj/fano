unit HeaderIntf;

interface
{$MODE OBJFPC}
{$INTERFACES CORBA}

type
    {------------------------------------------------
     interface for any class having capability to
     write HTTP header
     @author Zamrony P. Juhara <zamrony@yahoo.com>
    -----------------------------------------------}
    IHeaderInterface = interface
        function writeHeader() : IHeaderInterface;
    end;

implementation
end.
