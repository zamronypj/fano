{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RouteCollectionIntf;

interface

{$MODE OBJFPC}

uses

    RouteHandlerIntf;

type

    (*!------------------------------------------------
     * interface for any class that can set route handler
     * for various http verb
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IRouteCollection = interface
        ['{382B4D2E-0061-4727-8C79-291FCD39F798}']

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
    end;

implementation
end.
