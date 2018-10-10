unit DebugErrorHandlerImpl;

interface
{$H+}
uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf;

type

    {------------------------------------------------
     default error handler for debugging
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TDebugErrorHandler = class(TInterfacedObject, IErrorHandler, IDependency)
    private
        function getStackTrace(const e: Exception) : string;
        procedure printStackTrace(const e: Exception);
    public
        function handleError(const exc : Exception) : IErrorHandler;
    end;

implementation

    function TDebugErrorHandler.getStackTrace(const e : Exception) : string;
    var
        i: integer;
        frames: PPointer;
        report: string;
    begin
        report := '<!DOCTYPE html><html><head><title>Program exception</title></head><body>';
        report := report + '<h2>Program exception</h2>';
        if (e <> nil) then
        begin
            report := report +
                '<div>Exception class: ' + e.className + '</div>' + LineEnding  +
                '<div>Message: ' + e.message + '</div>'+ LineEnding;
        end;
        report := report + '<div>Stacktrace:</div>' + LineEnding;
        report := report + '<pre>' + LineEnding +
                  BackTraceStrFunc(ExceptAddr) + LineEnding;
        frames := ExceptFrames;
        for i := 0 to ExceptFrameCount - 1 do
        begin
            report := report + BackTraceStrFunc(frames[I]) + LineEnding;
        end;
        report := report + '</pre>';
        report := report + '</body></html>';
        result := report;
    end;

    procedure TDebugErrorHandler.printStackTrace(const e : Exception);
    begin
        writeln('Content-Type: text/html');
        writeln('Status: 500 Internal Server Error');
        writeln();
        writeln(getStackTrace(e));
    end;

    function TDebugErrorHandler.handleError(const exc : Exception) : IErrorHandler;
    begin
        printStackTrace(exc);
        result := self;
    end;
end.
