unit FactoryImpl;

interface

uses
    DependencyAwareIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf;

type
    {------------------------------------------------
     base class for any class having capability to create
     other object

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFactory = class(TInterfacedObject, IDependencyFactory)
    protected
        dependencyContainer : IDependencyContainer;
    public
        constructor create(const dc : IDependencyContainer);
        destructor destroy(); override;
        function build() : IDependencyAware; virtual; abstract;
    end;

implementation


    constructor TFactory.create(const dc : IDependencyContainer);
    begin
        dependencyContainer := dc;
    end;

    destructor TFactory.destroy();
    begin
        inherited destroy();
        dependencyContainer := nil;
    end;

end.
