{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
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
