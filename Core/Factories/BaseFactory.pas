unit BaseFactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyFactoryIntf
    DependencyContainerIntf;

type
    {------------------------------------------------
     interface for any class having capability to create object

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TBaseFactory = class(TInterfacedObject, IDependencyFactory)
    private
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware; virtual; abstract;
    end;

implementation

    constructor TBaseFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TBaseFactory.destroy();
    begin
        dependencyContainer := nil;
    end;

end.
