{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RouteDataTypes;

interface

{$MODE OBJFPC}

uses

    PlaceholderTypes,
    RouteHandlerIntf;

type


    (*!------------------------------------------------
     * Data structure for storing route data
     * for HTTP GET, PUT, POST, DELETE, PATCH, HEAD, OPTIONS
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
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