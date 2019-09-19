{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteHandlerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    RouteIntf,
    RequestHandlerIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * manage route data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRouteHandler = interface
        ['{BD3ACEAB-F00B-4102-A344-8014893279BF}']

        (*!-------------------------------------------
         * get route instance
         *--------------------------------------------
         * @return route instance
         *--------------------------------------------*)
        function getRoute() : IRoute;

        (*!-------------------------------------------
         * get request handler
         *--------------------------------------------
         * @return request handler
         *--------------------------------------------*)
        function getHandler() : IRequestHandler;
    end;

implementation
end.
