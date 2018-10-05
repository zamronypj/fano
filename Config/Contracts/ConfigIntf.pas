unit ConfigIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     get config
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IAppConfiguration = interface
        ['{054EE7FE-20CF-4E46-A9B2-37921D890E33}']
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
    end;

implementation
end.
