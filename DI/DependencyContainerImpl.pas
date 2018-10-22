{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}
unit DependencyContainerImpl;

interface

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
        function addDependency(
            const serviceName :string;
            const service : IDependencyFactory;
            const singleInstance :boolean
        ) : IDependencyContainer;
        procedure cleanUpDependencies();
    public
        constructor create(const dependencies :IDependencyList);
        destructor destroy(); override;

        (*!--------------------------------------------------------
         * Add factory instance to service registration as
         * single instance
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;

        (*!--------------------------------------------------------
         * Add factory instance to service registration as
         * multiple instance
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return current dependency container instance
         *---------------------------------------------------------*)
        function factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;

        (*!--------------------------------------------------------
         * get instance from service registration using its name.
         *---------------------------------------------------------
         * @param serviceName name of service
         * @return dependency instance
         *---------------------------------------------------------
         * if serviceName is registered with add(), then this method
         * will always return same instance. If serviceName is
         * registered using factory(), this method will return
         * different instance everytim get() is called.s
         *---------------------------------------------------------*)
        function get(const serviceName : string) : IDependency;
    end;

implementation

uses
    sysutils,
    EDependencyNotFoundImpl;

resourcestring

    sDependencyNotFound = 'Dependency %s not found';

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
     * @param service factory instance
     * @param singleInstance true if single instance otherwise false
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TDependencyContainer.addDependency(
        const serviceName : string;
        const service : IDependencyFactory;
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

        depRec^.factory := service;
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
    function TDependencyContainer.add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
    begin
        result := addDependency(serviceName, service, true);
    end;

    (*!--------------------------------------------------------
     * Add factory instance to service registration as
     * multiple instance
     *---------------------------------------------------------
     * @param serviceName name of service
     * @param service factory instance
     * @return current dependency container instance
     *---------------------------------------------------------*)
    function TDependencyContainer.factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
    begin
        result := addDependency(serviceName, service, false);
    end;

    (*!--------------------------------------------------------
     * get instance from service registration using its name.
     *---------------------------------------------------------
     * @param serviceName name of service
     * @return dependency instance
     *---------------------------------------------------------
     * if serviceName is registered with add(), then this method
     * will always return same instance. If serviceName is
     * registered using factory(), this method will return
     * different instance everytim get() is called.s
     *---------------------------------------------------------*)
    function TDependencyContainer.get(const serviceName : string) : IDependency;
    var depRec : PDependencyRec;
    begin
        depRec := dependencyList.find(serviceName);
        if (depRec = nil) then
        begin
            raise EDependencyNotFound.createFmt(sDependencyNotFound, [serviceName]);
        end;

        if (depRec^.singleInstance) then
        begin
            if (depRec^.instance = nil) then
            begin
                try
                    depRec^.instance := depRec^.factory.build(self);
                except
                    depRec^.instance := nil;
                    raise;
                end;
            end;
            result := depRec^.instance;
        end else
        begin
            try
                result := depRec^.factory.build(self);
            except
                result := nil;
                raise;
            end;
        end;
    end;

end.
