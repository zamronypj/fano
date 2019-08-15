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
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;

        (*!-------------------------------------------
         * get route argument data
         *--------------------------------------------*)
        function getArgs() : TArrayOfPlaceholders;

        (*!-------------------------------------------
         * get single route argument data
         *--------------------------------------------*)
        function getArg(const key : string) : TPlaceholder;
    end;

implementation
end.
