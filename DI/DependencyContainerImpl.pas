unit DependencyContainerImpl;

interface

uses
    contnrs,
    DependencyAwareIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    DependencyListIntf;

type

    {------------------------------------------------
     interface for any class having capability to manage
     dependency

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDependencyContainer = class(TInterfacedObject, IDependencyContainer)
    private
        dependencyList : IDependencyList;
        function addDependency(
            const serviceName :string;
            const service : IDependencyFactory;
            const singleInstance :boolean
        ) : IDependencyContainer;

    public
        constructor create(const dependencies :IDependencyList);
        destructor destroy(); override;

        function add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
        function get(const serviceName : string) : IDependencyAware;
    end;

implementation

uses
    EDependencyNotFoundImpl;

type

    TDependencyRec = record
        factory : IDependencyFactory;
        instance : IDependencyAware;
        singleInstance : boolean;
    end;
    PDependencyRec = ^TDependencyRec;

    constructor TDependencyContainer.create(const dependencies : IDependencyList);
    begin
        dependencyList := dependencies;
    end;

    destructor TDependencyContainer.destroy();
    var i, len:integer;
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
        dependencyList := nil;
    end;

    function TDependencyContainer.addDependency(
        const serviceName :string;
        const service : IDependencyFactory;
        const singleInstance :boolean
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
        depRec^.singleInstance := true;
        result := self;
    end;

    function TDependencyContainer.add(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
    begin
        result := addDependency(serviceName, service, true);
    end;

    function TDependencyContainer.factory(const serviceName :string; const service : IDependencyFactory) : IDependencyContainer;
    begin
        result := addDependency(serviceName, service, false);
    end;

    function TDependencyContainer.get(const serviceName : string) : IDependencyAware;
    var depRec : PDependencyRec;
    begin
        depRec := dependencyList.find(serviceName);
        if (depRec = nil) then
        begin
            raise EDependencyNotFound.Create('Dependency not found: ' + serviceName);
        end;

        if (depRec^.singleInstance) then
        begin
            if (depRec^.instance = nil) then
            begin
               depRec^.instance := depRec^.factory.build();
            end;
            result := depRec^.instance;
        end else
        begin
            result := depRec^.factory.build();
        end;
    end;

end.
