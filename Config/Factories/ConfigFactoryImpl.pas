unit ConfigFactoryImpl;

interface

uses
    ConfigFactoryIntf,
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TFanoConfig
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFanoConfigFactory = class (TFactory, IAppConfigurationFactory, IDependencyFactory)
    private
        configFilename : string;
    public
        constructor create(const dc : IDependencyContainer; const configFile :string);
        function build() : IDependency; override;
    end;

implementation

uses
    ConfigImpl;

    constructor TFanoConfigFactory.create(const dc : IDependencyContainer; const configFile : string);
    begin
        inherited create(dc);
        configFilename := configFile;
    end;

    function TFanoConfigFactory.build() : IDependency;
    begin
        result := TFanoConfig.create(configFilename);
    end;

end.
