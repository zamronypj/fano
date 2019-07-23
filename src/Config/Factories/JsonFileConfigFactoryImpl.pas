unit JsonFileConfigFactoryImpl;

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
    TJsonFileConfigFactory = class (TFactory, IDependencyFactory)
    private
        configFilename : string;
    public
        constructor create(const configFile :string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    JsonFileConfigImpl;

    constructor TJsonFileConfigFactory.create(const configFile : string);
    begin
        configFilename := configFile;
    end;

    function TJsonFileConfigFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TJsonFileConfig.create(configFilename);
    end;

end.
