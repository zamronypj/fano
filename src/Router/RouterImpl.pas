{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouterImpl;

interface

{$MODE OBJFPC}

uses

    RouteHandlerIntf,
    RouterIntf,
    RouteMatcherIntf,
    RouteListIntf,
    RouteDataTypes,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic class that can manage and retrieve routes
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouter = class(TInjectableObject, IRouter, IRouteMatcher)
    private
        routeList : IRouteList;

        function findRouteData(const routeName: string) : PRouteRec;
        function createEmptyRouteData(const routeName: string) : PRouteRec;
        function resetRouteData(const routeData : PRouteRec) : PRouteRec;
        function getRouteHandler(const requestMethod : string; const routeData :PRouteRec) : IRouteHandler;
    public
        constructor create(const routes : IRouteList);
        destructor destroy(); override;

        (*!------------------------------------------
         * set route handler for HTTP GET
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function get(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP POST
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function post(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP PUT
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function put(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP PATCH
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function patch(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP DELETE
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function delete(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP HEAD
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function head(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for HTTP OPTIONS
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function options(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for multiple HTTP verbs
         * ------------------------------------------
         * @param verbs array of http verbs, GET, POST, etc
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function map(
            const verbs : array of string;
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!------------------------------------------
         * set route handler for all HTTP verbs
         * ------------------------------------------
         * @param routeName regex pattern for route
         * @param routeHandler instance route handler
         * @return route handler instance
         *-------------------------------------------*)
        function any(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteHandler;

        (*!----------------------------------------------
         * find route handler based request method and uri
         * ----------------------------------------------
         * @param requestMethod GET, POST,.., etc
         * @param requestUri requested Uri
         * @return route handler instance
         *-----------------------------------------------*)
        function match(const requestMethod : string; const requestUri: string) : IRouteHandler;
    end;

implementation

uses

    SysUtils,
    RouteConsts,
    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl;


    constructor TRouter.create(const routes : IRouteList);
    begin
        routeList := routes;
    end;

    function TRouter.resetRouteData(const routeData : PRouteRec) : PRouteRec;
    begin
        routeData^.getRoute := nil;
        routeData^.postRoute := nil;
        routeData^.putRoute := nil;
        routeData^.patchRoute := nil;
        routeData^.deleteRoute := nil;
        routeData^.optionsRoute := nil;
        routeData^.headRoute := nil;
        routeData^.placeholders := nil;
        result := routeData;
    end;

    destructor TRouter.destroy();
    var i, len:integer;
       routeData : PRouteRec;
    begin
        inherited destroy();
        len := routeList.count();
        for i := len-1 downto 0 do
        begin
            routeData := routeList.get(i);
            resetRouteData(routeData);
            dispose(routeData);
        end;
        routeList := nil;
    end;

    function TRouter.createEmptyRouteData(const routeName: string) : PRouteRec;
    var routeData : PRouteRec;
    begin
        //route not yet found, create new data
        new(routeData);
        routeData := resetRouteData(routeData);
        routeList.add(routeName, routeData);
        result := routeData;
    end;

    function TRouter.findRouteData(const routeName: string) : PRouteRec;
    var routeData : PRouteRec;
    begin
        routeData := routeList.find(routeName);
        if (routeData = nil) then
        begin
            //route not yet found, create new data
            result := createEmptyRouteData(routeName);
        end else
        begin
            result := routeData;
        end;
    end;

    (*!------------------------------------------
     * set route handler for HTTP GET
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.get(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.getRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP POST
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.post(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.postRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP PUT
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.put(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.putRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP PATCH
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.patch(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.patchRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP DELETE
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.delete(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.deleteRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP HEAD
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.headRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for HTTP OPTIONS
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.options(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.optionsRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for multiple HTTP verbs
     * ------------------------------------------
     * @param verbs array of http verbs, GET, POST, etc
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.map(
        const verbs : array of string;
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
        i, len : integer;
        averb : string;
    begin
        routeData := findRouteData(routeName);
        len := high(verbs) - low(verbs) + 1;
        for i := 0 to len - 1 do
        begin
            averb := uppercase(verbs[i]);
            case averb of
                'GET' :  routeData^.getRoute := routeHandler;
                'POST' :  routeData^.postRoute := routeHandler;
                'PUT' :  routeData^.putRoute := routeHandler;
                'DELETE' :  routeData^.deleteRoute := routeHandler;
                'PATCH' :  routeData^.patchRoute := routeHandler;
                'OPTIONS' : routeData^.optionsRoute := routeHandler;
                'HEAD' :  routeData^.headRoute := routeHandler;
            end;
        end;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * set route handler for all HTTP verbs
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouter.any(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.getRoute := routeHandler;
        routeData^.postRoute := routeHandler;
        routeData^.putRoute := routeHandler;
        routeData^.deleteRoute := routeHandler;
        routeData^.patchRoute := routeHandler;
        routeData^.optionsRoute := routeHandler;
        routeData^.headRoute := routeHandler;
        result := routeHandler;
    end;

    (*!------------------------------------------
     * get route handler based on request method
     * ------------------------------------------
     * @param requestMethod GET, POST, etc
     * @param routeData instance route data
     * @return route handler instance or nil if not found
     *-------------------------------------------*)
    function TRouter.getRouteHandler(const requestMethod : string; const routeData :PRouteRec) : IRouteHandler;
    var routeHandler : IRouteHandler;
        method : string;
    begin
        method := uppercase(requestMethod);
        routeHandler := nil;
        case method of
            'GET' : routeHandler := routeData^.getRoute;
            'POST' : routeHandler := routeData^.postRoute;
            'PUT' : routeHandler := routeData^.putRoute;
            'DELETE' : routeHandler := routeData^.deleteRoute;
            'PATCH' : routeHandler := routeData^.patchRoute;
            'OPTIONS' : routeHandler := routeData^.optionsRoute;
            'HEAD' : routeHandler := routeData^.headRoute;
        end;
        result := routeHandler;
    end;

    (*!----------------------------------------------
     * find route handler based request method and uri
     * ----------------------------------------------
     * @param requestMethod GET, POST,.., etc
     * @param requestUri requested Uri
     * @return route handler instance
     *-----------------------------------------------*)
    function TRouter.match(const requestMethod : string; const requestUri : string) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := routeList.match(requestUri);

        if (routeData = nil) then
        begin
            raise ERouteHandlerNotFound.createFmt(
                sRouteNotFound,
                [requestMethod, requestUri]
            );
        end;

        result := getRouteHandler(requestMethod, routeData);

        if (result = nil) then
        begin
            raise EMethodNotAllowed.createFmt(
                sMethodNotAllowed,
                [requestMethod, requestUri]
            );
        end;

        result.setArgs(routeData^.placeholders);
    end;

end.
