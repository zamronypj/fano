{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit DependencyContainerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    contnrs,
    DependencyIntf,
    DependencyContainerIntf,
    DependencyListIntf;

type

    (*!------------------------------------------------
     * basic IDependencyContainer implementation class
     * having capability to manage dependency
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TDependencyContainer = class(TInterfacedObject, IDependencyContainer)
    private
        dependencyList : IDependencyList;

        (*!--------------------------------------------------------
         * Add factory instance to service registration as
         * single instance or multiple instance
         *---------------------------------------------------------
         * @param serviceName name of service
         * @param serviceFactory factory instance
         * @param singleInstance true if single instance otherwise false
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function addDependency(
            const serviceName : shortstring;
            const service : IDependencyFactory;
            const singleInstance : boolean
        ) : IDependencyContainer;

        procedure cleanUpDependencies();
    public
        (*!--------------------------------------------------------
         * constructor
         *---------------------------------------------------------
         * @param dependencies instance of list that will store dependencies
         *---------------------------------------------------------*)
        constructor create(const dependencies :IDependencyList);

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
         * get instance from service registration using its name.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return dependency instance
         *---------------------------------------------------------
         * if serviceName is registered with add(), then this method
         * will always return same instance. If serviceName is
         * registered using factory(), this method will return
         * different instance everytime get() is called
         *---------------------------------------------------------*)
        function get(const serviceName : shortstring) : IDependency;
    end;

implementation

uses
    sysutils,
    EDependencyNotFoundImpl,
    EInvalidFactoryImpl;

resourcestring

    sDependencyNotFound = 'Dependency %s not found';
    sInvalidFactory = 'Factory %s is invalid';

type

    TDependencyRec = record
        factory : IDependencyFactory;
        instance : IDependency;
        singleInstance : boolean;
    end;
    PDependencyRec = ^TDependencyRec;

    constructor TDependencyContainer.create(const dependencies : IDependencyList);
    begin
        dependencyList := dependencies;
    end;

    destructor TDependencyContainer.destroy();
    begin
        inherited destroy();
        cleanUpDependencies();
        dependencyList := nil;
    end;

    procedure TDependencyContainer.cleanUpDependencies();
    var i, len : integer;
        dep : PDependencyRec;
    begin
        len := dependencyList.count();
        for i := len-1 downto 0 do
        begin
            dep := dependencyList.get(i);
            dep^.factory := nil;
            dep^.instance := nil;
            dispose(dep);
            dependencyList.delete(i);
        end;
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * single instance or multiple instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param serviceFactory factory instance
     * @param singleInstance true if single instance otherwise false
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TDependencyContainer.addDependency(
        const serviceName : shortstring;
        const serviceFactory : IDependencyFactory;
        const singleInstance : boolean
    ) : IDependencyContainer;
    var depRec : PDependencyRec;
    begin
        depRec := dependencyList.find(serviceName);
        if (depRec = nil) then
        begin
           new(depRec);
           dependencyList.add(serviceName, depRec);
        end;

        depRec^.factory := serviceFactory;
        depRec^.instance := nil;
        depRec^.singleInstance := singleInstance;
        result := self;
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * single instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param service factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TDependencyContainer.add(
        const serviceName : shortstring;
        const serviceFactory : IDependencyFactory
    ) : IDependencyContainer;
    begin
        result := addDependency(serviceName, serviceFactory, true);
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * multiple instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param serviceFactory factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TDependencyContainer.factory(
        const serviceName : shortstring;
        const serviceFactory : IDependencyFactory
    ) : IDependencyContainer;
    begin
        result := addDependency(serviceName, serviceFactory, false);
    end;

    (*!--------------------------------------------------------
     * get instance from service registration using its name.
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
    function TDependencyContainer.get(const serviceName : shortstring) : IDependency;
    var depRec : PDependencyRec;
    begin
        depRec := dependencyList.find(serviceName);

        if (depRec = nil) then
        begin
            raise EDependencyNotFound.createFmt(sDependencyNotFound, [serviceName]);
        end;

        if (depRec^.factory = nil) then
        begin
            raise EInvalidFactory.createFmt(sInvalidFactory, [serviceName]);
        end;

        if (depRec^.singleInstance) then
        begin
            if (depRec^.instance = nil) then
            begin
                depRec^.instance := depRec^.factory.build(self);
            end;
            result := depRec^.instance;
        end else
        begin
            result := depRec^.factory.build(self);
        end;
    end;

end.
