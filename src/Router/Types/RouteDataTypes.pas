{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteDataTypes;

interface

{$MODE OBJFPC}

uses

    PlaceholderTypes,
    RequestHandlerIntf;

type


    (*!------------------------------------------------
     * Data structure for storing route data
     * for HTTP GET, PUT, POST, DELETE, PATCH, HEAD, OPTIONS
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouteRec = record
        getRoute : IRequestHandler;
        postRoute : IRequestHandler;
        putRoute : IRequestHandler;
        patchRoute : IRequestHandler;
        deleteRoute : IRequestHandler;
        optionsRoute : IRequestHandler;
        headRoute : IRequestHandler;

        placeholders : TArrayOfPlaceholders;
    end;
    PRouteRec = ^TRouteRec;

implementation



end.
