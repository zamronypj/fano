unit ConfigFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    FactoryImpl;

type
    {------------------------------------------------
     factory class for TFanoConfig
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TFanoConfigFactory = class (TFactory, IDependencyFactory)
    private
        configFilename : string;
    public
        constructor create(const configFile :string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses
    ConfigImpl;

    constructor TFanoConfigFactory.create(const configFile : string);
    begin
        configFilename := configFile;
    end;

    function TFanoConfigFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TFanoConfig.create(configFilename);
    end;

end.
