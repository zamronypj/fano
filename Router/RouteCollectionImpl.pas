{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RouteCollectionImpl;

interface

{$MODE OBJFPC}

uses
    RouteCollectionIntf,
    RouterImpl;

type

    (*!------------------------------------------------
     * basic class that can manage and retrieve routes
     *
     * This class will be deprecated. You should use IRouter
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * -----------------------------------------------*)
    TRouteCollection = class(TRouter, IRouteCollection)
    end;

implementation

end.
