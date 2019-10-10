{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ServiceContainerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyContainerIntf,
    ServiceContainerIntf,
    ServiceFactoryIntf,
    ServiceIntf;

type

    (*!------------------------------------------------
     * basic IServiceContainer implementation class
     * having capability to manage dependency
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TServiceContainer = class(TInterfacedObject, IDependencyContainer, IServiceContainer)
    private
        dependencyContainer : IDependencyContainer;
    public
        (*!--------------------------------------------------------
         * constructor
         *---------------------------------------------------------
         * @param di instance of IDependencyContainer
         *---------------------------------------------------------*)
        constructor create(const di :IDependencyContainer);

        (*!--------------------------------------------------------
         * destructor
         *---------------------------------------------------------*)
        destructor destroy(); override;

        (*!--------------------------------------------------------
         * Add factory instance to service registration as
         * single instance
         *---------------------------------------------------------
         * @param serviceName name of service
         * @param serviceFactory factory instance
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function add(const serviceName : shortstring; const serviceFactory : IDependencyFactory) : IDependencyContainer;

        (*!--------------------------------------------------------
         * Add factory instance to service registration as
         * multiple instance
         *---------------------------------------------------------
         * @param serviceName name of service
         * @param serviceFactory factory instance
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function factory(const serviceName : shortstring; const serviceFactory : IDependencyFactory) : IDependencyContainer;

        (*!--------------------------------------------------------
         * Add alias name to existing service
         *---------------------------------------------------------
         * @param aliasName alias name of service
         * @param serviceName actual name of service
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function alias(const aliasName: shortstring; const serviceName : shortstring) : IDependencyContainer;

        (*!--------------------------------------------------------
         * get instance from service registration using its name.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return dependency instance
         * @throws EDependencyNotFoundImpl exception when name is not registered
         *---------------------------------------------------------
         * if serviceName is registered with add(), then this method
         * will always return same instance. If serviceName is
         * registered using factory(), this method will return
         * different instance everytime get() is called.
         *---------------------------------------------------------*)
        function get(const serviceName : shortstring) : IDependency;

        (*!--------------------------------------------------------
         * test if service is already registered or not.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return boolean true if service is registered otherwise false
         *---------------------------------------------------------*)
        function has(const serviceName : shortstring) : boolean;

        (*!--------------------------------------------------------
         * register factory instance to service registration as
         * single instance
         *---------------------------------------------------------
         * @param service service to be register
         * @param serviceFactory factory instance
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function register(const service : IInterface; const serviceFactory : IServiceFactory) : IServiceContainer;

        (*!--------------------------------------------------------
         * register factory instance to service registration as
         * multiple instance
         *---------------------------------------------------------
         * @param service service to be registered
         * @param serviceFactory factory instance
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function registerMultiple(const service : IInterface; const serviceFactory : IServiceFactory) : IServiceContainer;

        (*!--------------------------------------------------------
         * register alias to existing service
         *---------------------------------------------------------
         * @param aliasService alias of service
         * @param serviceName actual service
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function registerAlias(const aliasService: IInterface; const service : IInterface) : IServiceContainer;

        (*!--------------------------------------------------------
         * resolve instance from service registration using its name.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return dependency instance
         * @throws EDependencyNotFoundImpl exception when name is not registered
         *---------------------------------------------------------
         * if service is registered with register(), then this method
         * will always return same instance. If service is
         * registered using registerMultiple(), this method will return
         * different instance everytime resolve() is called.
         *---------------------------------------------------------*)
        function resolve(const service : IInterface) : IService;

        (*!--------------------------------------------------------
         * test if service is already registered or not.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return boolean true if service is registered otherwise false
         *---------------------------------------------------------*)
        function isRegistered(const service : IInterface) : boolean;

    end;

implementation

uses

    SysUtils;

    constructor TServiceContainer.create(const di : IDependencyContainer);
    begin
        inherited create();
        dependencyContainer := di;
    end;

    destructor TServiceContainer.destroy();
    begin
        dependencyContainer := nil;
        inherited destroy();
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * single instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param service factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.add(
        const serviceName : shortstring;
        const serviceFactory : IDependencyFactory
    ) : IDependencyContainer;
    begin
        dependencyContainer.add(serviceName, serviceFactory);
        result := self;
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * multiple instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param serviceFactory factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.factory(
        const serviceName : shortstring;
        const serviceFactory : IDependencyFactory
    ) : IDependencyContainer;
    begin
        dependencyContainer.factory(serviceName, serviceFactory);
        result := self;
    end;

    (*!--------------------------------------------------------
     * Add alias name to existing service
     *---------------------------------------------------------
     * @param aliasName alias name of service
     * @param serviceName actual name of service
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.alias(const aliasName: shortstring; const serviceName : shortstring) : IDependencyContainer;
    begin
        dependencyContainer.alias(aliasName, serviceName);
        result := self;
    end;

    (*!--------------------------------------------------------
     * get instance from service registration using its name or alias.
     *---------------------------------------------------------
     * @param serviceName name of service
     * @return dependency instance
     * @throws EDependencyNotFound
     * @throws EInvalidFactory
     *---------------------------------------------------------
     * if serviceName is registered with add(), then this method
     * will always return same instance. If serviceName is
     * registered using factory(), this method will return
     * different instance everytime it is called.
     *---------------------------------------------------------*)
    function TServiceContainer.get(const serviceName : shortstring) : IDependency;
    begin
        result := dependencyContainer.get(serviceName);
    end;

    (*!--------------------------------------------------------
     * test if service is already registered or not.
     *---------------------------------------------------------
     * @param serviceName name of service
     * @return boolean true if service is registered otherwise false
     *---------------------------------------------------------
     * if serviceName is registered with add(), then this method
     * will always return same instance. If serviceName is
     * registered using factory(), this method will return
     * different instance everytim get() is called.s
     *---------------------------------------------------------*)
    function TServiceContainer.has(const serviceName : shortstring) : boolean;
    begin
        result := dependencyContainer.has(serviceName);
    end;

    (*!--------------------------------------------------------
     * register factory instance to service registration as
     * single instance
     *---------------------------------------------------------
     * @param service service to be register
     * @param serviceFactory factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.register(const service : IInterface; const serviceFactory : IServiceFactory) : IServiceContainer;
    begin
        add(GUIDToString(service), serviceFactory);
        result := self;
    end;

    (*!--------------------------------------------------------
     * register factory instance to service registration as
     * multiple instance
     *---------------------------------------------------------
     * @param service service to be registered
     * @param serviceFactory factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.registerMultiple(const service : IInterface; const serviceFactory : IServiceFactory) : IServiceContainer;
    begin
        factory(GUIDToString(service), serviceFactory);
        result := self;
    end;

    (*!--------------------------------------------------------
     * register alias to existing service
     *---------------------------------------------------------
     * @param aliasService alias of service
     * @param serviceName actual service
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TServiceContainer.registerAlias(const aliasService: IInterface; const service : IInterface) : IServiceContainer;
    begin
        alias(GUIDToString(aliasService), GUIDToString(service));
        result := self;
    end;

    (*!--------------------------------------------------------
     * resolve instance from service registration using its name.
     *---------------------------------------------------------
     * @param service service interface to resolve
     * @return dependency instance
     * @throws EDependencyNotFoundImpl exception when name is not registered
     *---------------------------------------------------------
     * if service is registered with register(), then this method
     * will always return same instance. If service is
     * registered using registerMultiple(), this method will return
     * different instance everytime resolve() is called.
     *---------------------------------------------------------*)
    function TServiceContainer.resolve(const service : IInterface) : IService;
    begin
        result := get(GUIDToString(service)) as IService;
    end;

    (*!--------------------------------------------------------
     * test if service is already registered or not.
     *---------------------------------------------------------
     * @param serviceName name of service
     * @return boolean true if service is registered otherwise false
     *---------------------------------------------------------*)
    function TServiceContainer.isRegistered(const service : IInterface) : boolean;
    begin
        result := has(GUIDToString(service));
    end;

end.
