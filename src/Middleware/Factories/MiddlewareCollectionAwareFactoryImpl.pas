{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MiddlewareCollectionAwareFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * middleware collection aware instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMiddlewareCollectionAwareFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    MiddlewareCollectionAwareImpl,
    MiddlewareCollectionImpl;

    function TMiddlewareCollectionAwareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TMiddlewareCollectionAware.create(
            TMiddlewareCollection.create(),
            TMiddlewareCollection.create()
        );
    end;
end.