unit ViewIntf;

interface

uses
    ResponseIntf,
    ViewParamsIntf;

type
    {------------------------------------------------
     interface for any class having capability as view
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IView = interface(IResponse)
        ['{04F99A16-DDBC-403B-A099-8BB44BE3CCC5}']
        function render(
            const templateName : string;
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;
    end;

implementation
end.
