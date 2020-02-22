unit NullConfigFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TFanoConfig
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TNullConfigFactory = class (TFactory, IDependencyFactory)
    public
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    NullConfigImpl;

    function TNullConfigFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TNullConfig.create();
    end;

end.
