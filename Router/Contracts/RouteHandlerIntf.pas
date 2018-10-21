{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit RouteHandlerIntf;

interface

{$H+}

uses
    MiddlewareIntf,
    MiddlewareCollectionAwareIntf,
    RequestHandlerIntf,
    PlaceholderTypes;

type
    {------------------------------------------------
     interface for any class having capability to
     handler route
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IRouteHandler = interface(IRequestHandler)
        ['{7F3C1F5B-4D60-441B-820F-400D76EAB1DC}']
        function getMiddlewares() : IMiddlewareCollectionAware;

        (*!-------------------------------------------
         * Set route argument data
         *--------------------------------------------*)
        function setArgs(const placeHolders : TArrayOfPlaceholders) : IRouteHandler;

        (*!-------------------------------------------
         * get route argument data
         *--------------------------------------------*)
        function getArgs() : TArrayOfPlaceholders;
    end;

implementation
end.
