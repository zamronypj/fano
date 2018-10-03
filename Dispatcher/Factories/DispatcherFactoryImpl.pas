unit DispatcherFactoryImpl;

interface

uses
    DispatcherFactoryIntf,

    DependencyAwareIntf;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcherFactory = class(TInterfacedObject, IDispatcherFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        function build() : IDependencyAware;
    end;

implementation

uses
    DispatcherImpl;

    function TDispatcherFactory.build() : IDependencyAware;
    begin
        result := TDispatcher.create();
    end;

end.
