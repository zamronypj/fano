{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit MiddlewareCollectionIntf;

interface

{$MODE OBJFPC}

uses

   MiddlewareIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * manage one or more middlewares
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IMiddlewareCollection = interface
        ['{DF2C4336-6849-4A50-AACE-3676CD9FB395}']
        function add(const middleware : IMiddleware) : IMiddlewareCollection;
        function count() : integer;
        function get(const indx : integer) : IMiddleware;
        function merge(const middlewares : IMiddlewareCollection) : IMiddlewareCollection;
    end;

implementation

end.
