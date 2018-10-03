unit ConfigIntf;

interface

type
    {------------------------------------------------
     interface for any class having capability to
     get config
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IWebConfiguration = interface
        ['{35BE40ED-4D09-4BF7-8303-8ABB606D9707}']
        function getString(const configName : string) : string;
        function getInt(const configName : string) : integer;
    end;

implementation
end.
