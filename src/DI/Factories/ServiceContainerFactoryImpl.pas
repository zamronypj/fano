{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ServiceContainerFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyContainerIntf;

type

    (*!------------------------------------------------
     * class for any class having capability to create
     * basisc
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TServiceContainerFactory = class(TInterfacedObject, IContainerFactory)
    public

        (*!---------------------------------------------------
         * build class instance
         *----------------------------------------------------
         * @param container dependency container instance
         *---------------------------------------------------*)
        function build() : IDependencyContainer;
    end;

implementation

uses

    ServiceContainerImpl,
    DependencyContainerImpl,
    DependencyListImpl;

    (*!---------------------------------------------------
     * build class instance
     *----------------------------------------------------
     * @param container dependency container instance
     *---------------------------------------------------*)
    function TServiceContainerFactory.build() : IDependencyContainer;
    begin
        result := TServiceContainer.create(
            TDependencyContainer.create(TDependencyList.create())
        );
    end;

end.
