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

uses
    MiddlewareIntf,
    MiddlewareCollectionAwareIntf,
    RequestHandlerIntf,
    PlaceholderTypes;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * handler route
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRouteHandler = interface(IRequestHandler)
        ['{7F3C1F5B-4D60-441B-820F-400D76EAB1DC}']

        (*!-------------------------------------------
         * Set route argument data
         *--------------------------------------------
         * @param placeHolders array of placeholders
         * @return current instance
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;

        (*!-------------------------------------------
         * get route argument data
         *--------------------------------------------
         * @return current array of placeholders
         *--------------------------------------------*)
        function getArgs() : TArrayOfPlaceholders;

        (*!-------------------------------------------
         * get single route argument data
         *--------------------------------------------
         * @param key name of argument
         * @return placeholder
         *--------------------------------------------*)
        function getArg(const key : shortstring) : TPlaceholder;
    end;

implementation
end.
