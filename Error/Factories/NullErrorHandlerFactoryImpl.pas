unit NullErrorHandlerFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TNullErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    NullErrorHandlerImpl;

    function TNullErrorHandlerFactory.build() : IDependency;
    begin
        result := TNullErrorHandler.create();
    end;

end.
