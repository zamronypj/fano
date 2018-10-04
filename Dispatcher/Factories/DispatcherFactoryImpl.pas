unit DispatcherFactoryImpl;

interface

uses
    DispatcherFactoryIntf,
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     interface for any class having capability to create
     dispatcher instance

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDispatcherFactory = class(TFactory, IDispatcherFactory, IDependencyFactory)
    public
        function build() : IDependencyAware; override;
    end;

implementation

uses
    RouteMatcherIntf,
    DispatcherImpl,
    RequestFactoryImpl,
    ResponseFactoryImpl;

    function TDispatcherFactory.build() : IDependencyAware;
    begin
        result := TDispatcher.create(
            dependencyContainer.get('router') as IRouteMatcher,
            TResponseFactory.create(dependencyContainer),
            TRequestFactory.create(dependencyContainer)
        );
    end;

end.
