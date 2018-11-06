{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullMiddlewareCollectionAwareFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * basic class having capability to create
     * null middleware collection  aware instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNullMiddlewareCollectionAwareFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    MiddlewareCollectionAwareImpl,
    NullMiddlewareCollectionImpl;

    function TNullMiddlewareCollectionAwareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TMiddlewareCollectionAware.create(
            TNullMiddlewareCollection.create(),
            TNullMiddlewareCollection.create()
        );
    end;
end.
