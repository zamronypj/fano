unit RouteDataTypes;

interface

uses
    PlaceholderTypes,
    RouteHandlerIntf;

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

        placeholders : TArrayOfPlaceholders;
    end;
    PRouteRec = ^TRouteRec;

implementation



end.