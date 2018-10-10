unit ErrorHandlerImpl;

interface
{$H+}
uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf;

type

    {------------------------------------------------
     default error handler
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TErrorHandler = class(TInterfacedObject, IErrorHandler, IDependency)
    public
        function handleError(const exc : Exception) : IErrorHandler;
    end;

implementation

    function TErrorHandler.handleError(const exc : Exception) : IErrorHandler;
    begin
        writeln('Content-Type: text/html');
        writeln('Status: 500 Internal Server Error');
        writeln();
        writeln(
            '<!DOCTYPE html><html><head><title>Program exception</title></head><body>' +
              '<h1>Program exception</h1>' +
              '<div>Exception class: ' + exc.className + '</div>' +
              '<div>Message: ' + exc.message + '</div>'+
            '</body></html>'
        );
        result := self;
    end;
end.
