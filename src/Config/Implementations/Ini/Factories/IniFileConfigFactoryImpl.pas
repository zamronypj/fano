unit IniFileConfigFactoryImpl;

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
    TIniFileConfigFactory = class (TFactory, IDependencyFactory)
    private
        configFilename : string;
    public
        constructor create(const configFile :string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    IniFileConfigImpl;

    constructor TIniFileConfigFactory.create(const configFile : string);
    begin
        configFilename := configFile;
    end;

    function TIniFileConfigFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TIniFileConfig.create(configFilename);
    end;

end.
