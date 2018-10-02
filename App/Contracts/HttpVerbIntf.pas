unit HttpVerbIntf;

interface

uses RouteHandlerIntf;

type
    {------------------------------------------------
     interface for any class that can set http verb
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IHttpVerb = interface

        //HTTP GET Verb handler
        function get(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP POST Verb handler
        function post(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP PUT Verb handler
        function put(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP DELETE Verb handler
        function delete(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

        //HTTP HEAD Verb handler
        function head(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IHttpVerb;

    end;

implementation
end.
