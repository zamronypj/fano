unit RouteFinderIntf;

interface

uses RouteHandlerIntf;

type
    {------------------------------------------------
     interface for any class that can find a route by name
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRouteFinder = interface
        ['{CA7D9639-1B26-4B44-8C4B-794A4562CD75}']
        function find(const requestMethod : string; const routeName: string) : IRouteHandler;
    end;

implementation
end.
