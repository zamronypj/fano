{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit NullErrorHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf,
    BaseErrorHandlerImpl;

type

    {------------------------------------------------
     default error handler to surpress error message
     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}
    TNullErrorHandler = class(TBaseErrorHandler, IErrorHandler, IDependency)
    public
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler; override;
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
