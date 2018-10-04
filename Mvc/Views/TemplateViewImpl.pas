unit TemplateViewImpl;

interface

uses
    ResponseIntf,
    ViewParamsIntf,
    ViewIntf,
    OutputBufferIntf;

type
    {------------------------------------------------
     View that can render from a HTML template string
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TTemplateView = class(TInterfacedObject, IView, IResponse)
    private
        template : string;
        outputBuffer : IOutputBuffer;
    public
        constructor create(
            const outputBufferInst : IOutputBuffer;
            const templateSrc : string
        ); virtual;
        destructor destroy(); override;

        function render(
            const viewParams : IViewParameters;
            const response : IResponse
        ) : IResponse;

        function write() : IResponse;
    end;

implementation

    constructor TTemplateView.create(
        const outputBufferInst : IOutputBuffer;
        const templateSrc : string
    );
    begin
        outputBuffer := outputBufferInst;
        template := templateSrc;
    end;

    destructor TTemplateView.destroy();
    begin
        inherited destroy();
        outputBuffer := nil;
    end;

    function TTemplateView.render(
        const viewParams : IViewParameters;
        const response : IResponse
    ) : IResponse;
    begin
        outputBuffer.beginBuffering();
        try
            writeln('Content-Type: text/html');
            writeln();
            writeln(template);
        finally
            outputBuffer.endBuffering();
        end;
        result := self;
    end;

    function TTemplateView.write() : IResponse;
    begin
        writeln(outputBuffer.flush());
        result := self;
    end;

end.
