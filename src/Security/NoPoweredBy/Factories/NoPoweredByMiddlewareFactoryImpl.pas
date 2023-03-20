{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NoPoweredByMiddlewareFactoryImpl;

interface

{$MODE OBJFPC}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl,
    RequestHandlerIntf;

type

    (*!------------------------------------------------
     * factory class for TNoPoweredByMiddleware
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TNoPoweredByMiddlewareFactory = class(TFactory, IDependencyFactory)
    public

        (*!---------------------------------------
         * build middleware instance
         *----------------------------------------
         * @param container dependency container
         * @return instance of middleware
         *----------------------------------------*)
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    NoPoweredByMiddlewareImpl;


    function TNoPoweredByMiddlewareFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TNoPoweredByMiddleware.create();
    end;

end.
