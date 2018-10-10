unit NullErrorHandlerImpl;

interface
{$H+}
uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf;

type

    {------------------------------------------------
     default error handler to surpress error message
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TNullErrorHandler = class(TInterfacedObject, IErrorHandler, IDependency)
    private
    public
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler;
    end;

implementation

    function TNullErrorHandler.handleError(
        const exc : Exception;
        const status : integer = 500;
        const msg : string  = 'Internal Server Error'
    ) : IErrorHandler;
    begin
        writeln('Content-Type: text/html');
        writeln('Status: ', intToStr(status), ' ', msg);
        writeln();
        writeln('');
    end;
end.
