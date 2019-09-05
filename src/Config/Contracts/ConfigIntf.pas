unit ConfigIntf;

interface

{$MODE OBJFPC}
{$H+}

type
    {------------------------------------------------
     interface for any class having capability to
     get config
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IAppConfiguration = interface
        ['{054EE7FE-20CF-4E46-A9B2-37921D890E33}']
        function getString(const configName : string; const defaultValue : string = '') : string;
        function getInt(const configName : string; const defaultValue : integer = 0) : integer;
        function getBool(const configName : string; const defaultValue : boolean = false) : boolean;
    end;

implementation
end.
