unit DebugErrorHandlerFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TDebugErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    DebugErrorHandlerImpl;

    function TDebugErrorHandlerFactory.build() : IDependency;
    begin
        result := TDebugErrorHandler.create();
    end;

end.
