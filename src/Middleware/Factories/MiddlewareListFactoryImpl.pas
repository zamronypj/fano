{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareListFactoryImpl;

interface

{$MODE OBJFPC}

uses

    MiddlewareListFactoryIntf,
    MiddlewareListItemIntf;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware collection aware instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareListFactory = class(TInterfacedObject IMiddlewareListFactory)
    public
        function build() : IMiddlewareListItem;
    end;

implementation

uses

    MiddlewareListImpl;

    function TMiddlewareListFactory.build() : IMiddlewareListItem;
    begin
        result := TMiddlewareList.create();
    end;
end.
