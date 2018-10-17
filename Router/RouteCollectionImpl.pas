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

        //HTTP GET Verb handler
        function get(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP POST Verb handler
        function post(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP PUT Verb handler
        function put(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP PATCH Verb handler
        function patch(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP DELETE Verb handler
        function delete(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP HEAD Verb handler
        function head(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        //HTTP OPTIONS Verb handler
        function options(
            const routeName: string;
            const routeHandler : IRouteHandler
        ) : IRouteCollection;

        function find(const requestMethod : string; const routeName: string) : IRouteHandler;
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

    //HTTP GET Verb handler
    function TRouteCollection.get(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.getRoute := routeHandler;
        result := self;
    end;

    //HTTP POST Verb handler
    function TRouteCollection.post(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.postRoute := routeHandler;
        result := self;
    end;

    //HTTP PUT Verb handler
    function TRouteCollection.put(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.putRoute := routeHandler;
        result := self;
    end;

    //HTTP PATCH Verb handler
    function TRouteCollection.patch(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.patchRoute := routeHandler;
        result := self;
    end;

    //HTTP DELETE Verb handler
    function TRouteCollection.delete(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.deleteRoute := routeHandler;
        result := self;
    end;

    //HTTP HEAD Verb handler
    function TRouteCollection.head(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.headRoute := routeHandler;
        result := self;
    end;

    //HTTP HEAD Verb handler
    function TRouteCollection.options(
        const routeName: string;
        const routeHandler : IRouteHandler
    ) : IRouteCollection;
    var routeData : PRouteRec;
    begin
        routeData := findRouteData(routeName);
        routeData^.optionsRoute := routeHandler;
        result := self;
    end;

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
        result := routeHandler
    end;

    function TRouteCollection.find(const requestMethod : string; const routeName: string) : IRouteHandler;
    var routeData : PRouteRec;
    begin
        routeData := routeList.find(routeName);
        if (routeData = nil) then
        begin
            raise ERouteHandlerNotFound.createFmt(
                sRouteNotFound,
                [requestMethod, routeName]
            );
        end;
        result := getRouteHandler(requestMethod, routeData);
        if (result = nil) then
        begin
            raise EMethodNotAllowed.createFmt(
                sMethodNotAllowed,
                [requestMethod, routeName]
            );
        end;
    end;

end.
