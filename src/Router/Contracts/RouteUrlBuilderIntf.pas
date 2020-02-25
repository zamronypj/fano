{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteUrlBuilderIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyContainerIntf,
    RouterIntf;

type

    (*!------------------------------------------------
     * interface for any class that can build routes
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRouteUrlBuilder = interface
        ['{6359E520-4117-48E0-8847-34A4D6853F9B}']

        (*!----------------------------------------------
         * build absolute URL from route name
         * ----------------------------------------------
         * @param routeName name of route
         * @param data key value pair
         * @return absolute URL
         *-----------------------------------------------*)
        function absoluteUrl(
            const routeName : string;
            const data : IReadOnlyKeyValuePair
        ) : string;

        (*!----------------------------------------------
         * build relative URL from route name
         * ----------------------------------------------
         * @param routeName name of route
         * @param data key value pair
         * @return relative URL
         *-----------------------------------------------*)
        function relativeUrl(
            const routeName : string;
            const data : IReadOnlyKeyValuePair
        ) : string;
    end;

implementation
end.
