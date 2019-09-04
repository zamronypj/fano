{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouterIntf;

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
    IRouter = interface
        ['{786EC9AF-C843-4B2E-9729-9146FAE8DDE3}']

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
    end;

implementation
end.
