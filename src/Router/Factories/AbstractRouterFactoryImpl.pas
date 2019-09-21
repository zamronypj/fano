{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractRouterFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    MiddlewareCollectionAwareFactoryIntf;

type

    (*!------------------------------------------------
     * Factory class for route collection using
     * TSimpleRouteList
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAbstractRouterFactory = class(TFactory, IDependencyFactory)
    private
        fMiddlewareCollectionAwareFactory : IMiddlewareCollectionAwareFactory;
    protected
        function getMiddlewareFactory() : IMiddlewareCollectionAwareFactory;
    public
        constructor create();
        destructor destroy(); override;
        function middlewareCollectionAwareFactory(const aFactory : IMiddlewareCollectionAwareFactory) : TAbstractRouterFactory;
    end;

implementation

uses

    MiddlewareCollectionAwareFactoryImpl;

    constructor TAbstractRouterFactory.create();
    begin
        fMiddlewareCollectionAwareFactory := nil;
    end;

    destructor TAbstractRouterFactory.destroy();
    begin
        fMiddlewareCollectionAwareFactory := nil;
        inherited destroy();
    end;

    function TAbstractRouterFactory.getMiddlewareFactory() : IMiddlewareCollectionAwareFactory;
    begin
        if (fMiddlewareCollectionAwareFactory = nil) then
        begin
            fMiddlewareCollectionAwareFactory := TMiddlewareCollectionAwareFactory.create();
        end;
        result := fMiddlewareCollectionAwareFactory;
    end;

    function TAbstractRouterFactory.middlewareCollectionAwareFactory(const aFactory : IMiddlewareCollectionAwareFactory) : TAbstractRouterFactory;
    begin
        fMiddlewareCollectionAwareFactory := aFactory;
        result := self;
    end;
end.
