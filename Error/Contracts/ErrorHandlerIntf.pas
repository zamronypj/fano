unit ErrorHandlerIntf;

interface
{$H+}
uses
    sysutils;

type

    {------------------------------------------------
     interface for any application
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    IErrorHandler = interface
        ['{2D6BF281-BBF9-41A0-BE5D-33E84E39B1C6}']
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler;
    end;

implementation
end.
