unit RequestImpl;

interface
{$H+}

uses
    EnvironmentIntf,
    RequestIntf;

type
    {------------------------------------------------
     interface for any class having capability as
     HTTP request
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TRequest = class(TInterfacedObject, IRequest)
    private
        webEnvironment : ICGIEnvironment;
    public
        constructor create(const env : ICGIEnvironment);
        destructor destroy(); override;
        function getQueryParam(const key: string) : string;
        function getCookieParam(const key: string) : string;
    end;

implementation
    constructor TRequest.create(const env : ICGIEnvironment);
    begin
        webEnvironment := env;
    end;

    destructor TRequest.destroy();
    begin
        webEnvironment := nil;
    end;

    function TRequest.getQueryParam(const key: string) : string;
    begin
        //TODO:
        result := '';
    end;

    function TRequest.getCookieParam(const key: string) : string;
    begin
        //TODO:
        result := '';
    end;
end.
