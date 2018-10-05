unit ConfigFactoryImpl;

interface

uses
    ConfigFactoryIntf,
    DependencyAwareIntf,
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
        function build() : IDependencyAware; override;
    end;

implementation

uses
    ConfigImpl;

    constructor TFanoConfigFactory.create(const dc : IDependencyContainer; const configFile : string);
    begin
        inherited create(dc);
        configFilename := configFile;
    end;

    function TFanoConfigFactory.build() : IDependencyAware;
    begin
        result := TFanoConfig.create(configFilename);
    end;

end.
