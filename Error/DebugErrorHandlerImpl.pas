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
    public
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler;
    end;

implementation

    function TDebugErrorHandler.getStackTrace(const e : Exception) : string;
    var
        i: integer;
        frames: PPointer;
    begin
        result := '<!DOCTYPE html><html><head><title>Program exception</title></head><body>';
        result := result + '<h2>Program exception</h2>';
        if (e <> nil) then
        begin
            result := result +
                '<div>Exception class: ' + e.className + '</div>' + LineEnding  +
                '<div>Message: ' + e.message + '</div>'+ LineEnding;
        end;

        result := result + '<div>Stacktrace:</div>' + LineEnding +
            '<pre>' + LineEnding + BackTraceStrFunc(ExceptAddr) + LineEnding;

        frames := ExceptFrames;
        for i := 0 to ExceptFrameCount - 1 do
        begin
            result := result + BackTraceStrFunc(frames[I]) + LineEnding;
        end;
        result := result + '</pre></body></html>';
    end;

    function TDebugErrorHandler.handleError(
        const exc : Exception;
        const status : integer = 500;
        const msg : string  = 'Internal Server Error'
    ) : IErrorHandler;
    begin
        writeln('Content-Type: text/html');
        writeln('Status: '+ intToStr(status) + ' ' + msg);
        writeln();
        writeln(getStackTrace(exc));
        result := self;
    end;
end.
