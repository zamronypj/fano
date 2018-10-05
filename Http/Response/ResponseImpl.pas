unit ResponseImpl;

interface

uses
    EnvironmentIntf,
    ResponseIntf;

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP response
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TResponse = class(TInterfacedObject, IResponse)
    private
        webEnvironment : ICGIEnvironment;
    public
        constructor create(const env : ICGIEnvironment);
        destructor destroy(); override;
        function write() : IResponse;
    end;

implementation

    constructor TResponse.create(const env : ICGIEnvironment);
    begin
        webEnvironment := env;
    end;

    destructor TResponse.destroy();
    begin
        webEnvironment := nil;
    end;

    function TResponse.write() : IResponse;
    begin
        //TODO:
        result := self;
    end;
end.
