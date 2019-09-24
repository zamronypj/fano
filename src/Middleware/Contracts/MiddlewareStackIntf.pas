{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareStackIntf;

interface

{$MODE OBJFPC}

uses

    MiddlewareStackIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability
     * as middleware link
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IMiddlewareStack = interface
        ['{39FCE1D4-0B0D-4F02-92D2-019583DC6663}']

        function getFirst() : IMiddlewareLink;
        property first : IMiddlewareLink read getFirst;
    end;

implementation
end.
