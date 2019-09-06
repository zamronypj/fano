{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeServiceProviderImpl;

interface

{$MODE OBJFPC}

uses

    ServiceProviderIntf,
    DependencyContainerIntf;

type

    (*!-----------------------------------------------
     * Base class that can register service using array
     * of external service providers
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TCompositeServiceProvider = class(TInterfacedObject, IServiceProvider)
    private
        fProviders : array of IServiceProvider;
    public
        constructor create(const providers : array of IServiceProvider);
        destructor destroy(); override;

        (*!--------------------------------------------------------
         * register all services
         *---------------------------------------------------------
         * @param container service container
         *---------------------------------------------------------*)
        procedure register(const container : IDependencyContainer);

    end;

implementation

    constructor TCompositeServiceProvider.create(const providers : array of IServiceProvider);
    begin
        fProviders := providers;
    end;

    destructor TCompositeServiceProvider.destroy();
    begin
        fProviders := nil;
        inherited destroy();
    end;

    (*!--------------------------------------------------------
     * register all services
     *---------------------------------------------------------
     * @param container service container
     *---------------------------------------------------------*)
    procedure TCompositeServiceProvider.register(const container : IDependencyContainer);
    var i : integer;
    begin
        for i:= low(fProviders) to high(fProviders) do
        begin
            fProviders[i].register(container);
        end;
    end;
end.
