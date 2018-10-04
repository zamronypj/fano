unit TemplateViewImpl;

interface

uses
    ResponseIntf,
    ViewParamsIntf,
    ViewIntf;

type
    {------------------------------------------------
     View that can render from a HTML template string
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateView = class(TInterfacedObject, IView, IResponse)
    private
        template : string;
    public
        constructor create(const templateSrc : string); virtual;

        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;

        function write() : IResponse;
    end;

implementation

    constructor TTemplateView.create(const templateSrc : string);
    begin
        template := templateSrc;
    end;

    function TTemplateView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    begin
        writeln('Content-Type: text/html');
        writeln();
        writeln(template);
        result := self;
    end;

    function TTemplateView.write() : IResponse;
    begin
        writeln('Content-Type: text/html');
        writeln();
        writeln(template);
        result := self;
    end;

end.
