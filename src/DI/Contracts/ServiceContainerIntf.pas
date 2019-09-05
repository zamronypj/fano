{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ServiceContainerIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    ServiceIntf,
    ServiceFactoryIntf;

type

    {------------------------------------------------
     interface for any class having capability to manage
     dependency

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IServiceContainer = interface
        ['{BC4A8D34-FE8E-4EA3-A7EB-51A92889DA66}']

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
         * if serviceName is registered with add(), then this method
         * will always return same instance. If serviceName is
         * registered using factory(), this method will return
         * different instance everytim get() is called.
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

end.
