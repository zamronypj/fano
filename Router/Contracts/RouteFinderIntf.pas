unit RouteFinderIntf;

interface

uses RouteHandlerIntf;

type
    {------------------------------------------------
     interface for any class that can find a route by name
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRouteFinder = interface
        function find(const requestMethod : string; const routeName: string) : IRouteHandler;
    end;

implementation
end.
