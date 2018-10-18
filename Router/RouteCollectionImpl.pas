{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RouteCollectionImpl;

interface

uses
    contnrs,
    RouteHandlerIntf,
    RouteCollectionIntf,
    RouteMatcherIntf,
    RouteListIntf,
    DependencyIntf;

type
    //Route data for HTTP GET, PUT, POST, DELETE, PATCH, HEAD, OPTIONS
    TRouteRec = record
        getRoute : IRouteHandler;
        postRoute : IRouteHandler;
        putRoute : IRouteHandler;
        patchRoute : IRouteHandler;
        deleteRoute : IRouteHandler;
        optionsRoute : IRouteHandler;
        headRoute : IRouteHandler;
    end;

    PRouteRec = ^TRouteRec;

    {------------------------------------------------
     interface for any class that can set http verb
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRouteCollection = class(TInterfacedObject, IDependency, IRouteCollection, IRouteMatcher)
    private
        routeList : IRouteList;

        function findRouteData(const routeName: string) : PRouteRec;
        function createEmptyRouteData(const routeName: string) : PRouteRec;
        function resetRouteData(const routeData : PRouteRec) : PRouteRec;
        procedure destroyRouteData(var routeData : PRouteRec);
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

        (*!----------------------------------------------
         * find route handler based request method and uri
         * ----------------------------------------------
         * @param requestMethod GET, POST,.., etc
         * @param requestUri requested Uri
         * @return route handler instance
         *-----------------------------------------------*)
        function find(const requestMethod : string; const requestUri: string) : IRouteHandler;
    end;

implementation

uses

    ERouteHandlerNotFoundImpl,
    EMethodNotAllowedImpl;

resourcestring

    sRouteNotFound = 'Route not found. Method: %s Uri: %s';
    sMethodNotAllowed = 'Method not allowed. Method: %s Uri: %s';

    constructor TRouteCollection.create(const routes : IRouteList);
    begin
        routeList := routes;
    end;

    function TRouteCollection.resetRouteData(const routeData : PRouteRec) : PRouteRec;
    begin
        routeData^.getRoute := nil;
        routeData^.postRoute := nil;
        routeData^.putRoute := nil;
        routeData^.patchRoute := nil;
        routeData^.deleteRoute := nil;
        routeData^.optionsRoute := nil;
        routeData^.headRoute := nil;
        result := routeData;
    end;

    procedure TRouteCollection.destroyRouteData(var routeData : PRouteRec);
    begin
        routeData := resetRouteData(routeData);
        dispose(routeData);
    end;

    destructor TRouteCollection.destroy();
    var i, len:integer;
       routeData :PRouteRec;
    begin
        inherited destroy();
        len := routeList.count();
        for i := len-1 downto 0 do
        begin
            routeData := routeList.get(i);
            destroyRouteData(routeData);
            routeList.delete(i);
        end;
        routeList := nil;
    end;

    function TRouteCollection.createEmptyRouteData(const routeName: string) : PRouteRec;
    var routeData : PRouteRec;
    begin
        //route not yet found, create new data
        new(routeData);
        routeData := resetRouteData(routeData);
        self.routeList.add(routeName, routeData);
        result := routeData;
    end;

    function TRouteCollection.findRouteData(const routeName: string) : PRouteRec;
    var routeData : PRouteRec;
    begin
        routeData := routeList.find(routeName);
        if (routeData = nil) then
        begin
           //route not yet found, create new data
           result := createEmptyRouteData(routeName);
        end else
        begin
           result := routeData
        end;
    end;

    (*!------------------------------------------
     * set route handler for HTTP GET
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouteCollection.get(
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
    function TRouteCollection.post(
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
    function TRouteCollection.put(
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
    function TRouteCollection.patch(
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
    function TRouteCollection.delete(
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
    function TRouteCollection.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.headRoute := routeHandler;
        result := self;
    end;

    (*!------------------------------------------
     * set route handler for HTTP OPTIONS
     * ------------------------------------------
     * @param routeName regex pattern for route
     * @param routeHandler instance route handler
     * @return route handler instance
     *-------------------------------------------*)
    function TRouteCollection.options(
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
     * get route handler based on request method
     * ------------------------------------------
     * @param requestMethod GET, POST, etc
     * @param routeData instance route data
     * @return route handler instance or nil if not found
     *-------------------------------------------*)
    function TRouteCollection.getRouteHandler(const requestMethod : string; const routeData :PRouteRec) : IRouteHandler;
    var routeHandler : IRouteHandler;
    begin
        routeHandler := nil;
        case requestMethod of
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
    function TRouteCollection.find(const requestMethod : string; const requestUri : string) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := routeList.find(requestUri);
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
    end;

end.
