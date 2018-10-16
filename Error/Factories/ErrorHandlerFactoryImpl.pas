unit ErrorHandlerFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    ErrorHandlerImpl;

    function TErrorHandlerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TErrorHandler.create();
    end;

end.
