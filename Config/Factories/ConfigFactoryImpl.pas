unit ConfigFactoryImpl;

interface

uses
    DependencyIntf,
    DependencyContainerIntf,
    DependencyFactoryIntf,
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
        function build() : IDependency; override;
    end;

implementation

uses
    ConfigImpl;

    constructor TFanoConfigFactory.create(const configFile : string);
    begin
        configFilename := configFile;
    end;

    function TFanoConfigFactory.build() : IDependency;
    begin
        //result := TFanoConfig.create(configFilename);
        result := nil;
    end;

end.
