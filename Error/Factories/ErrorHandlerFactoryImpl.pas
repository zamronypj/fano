unit ErrorHandlerFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyFactoryIntf,
    DependencyContainerIntf,
    FactoryImpl;

type

    TErrorHandlerFactory = class(TFactory, IDependencyFactory)
    public
        function build() : IDependency; override;
    end;

implementation

uses
    ErrorHandlerImpl;

    function TErrorHandlerFactory.build() : IDependency;
    begin
        result := TErrorHandler.create();
    end;

end.
