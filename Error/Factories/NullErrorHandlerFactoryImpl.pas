unit NullErrorHandlerFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TNullErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    NullErrorHandlerImpl;

    function TNullErrorHandlerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TNullErrorHandler.create();
    end;

end.
