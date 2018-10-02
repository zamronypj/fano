unit ConfigIntf;

interface
{$MODE OBJFPC}
{$INTERFACES CORBA}

type
    {------------------------------------------------
     interface for any class having capability to
     get config
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebConfiguration = interface
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
    end;

implementation
end.
