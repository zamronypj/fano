{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteCollectionIntf;

interface

{$MODE OBJFPC}

uses

    RouterIntf;

type

    (*!------------------------------------------------
     * interface for any class that can set route handler
     * for various http verb
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IRouteCollection = interface(IRouter)
        ['{382B4D2E-0061-4727-8C79-291FCD39F798}']
    end;

implementation
end.
