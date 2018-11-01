{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit AjaxErrorHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    sysutils,
    DependencyIntf,
    ErrorHandlerIntf,
    BaseErrorHandlerImpl;

type

    (*!---------------------------------------------------
     * default error handler for debugging that returns
     * error response as JSON
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    TAjaxErrorHandler = class(TBaseErrorHandler, IErrorHandler, IDependency)
    private
        function getStackTrace(const e: Exception) : string;
    public
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler; override;
    end;

implementation

    function TAjaxErrorHandler.getStackTrace(const e : Exception) : string;
    var
        i, len: integer;
        frames: PPointer;
    begin
        result := '{';
        if (e <> nil) then
        begin
            result := result +
                '"exception" : "' + e.className + '",' + LineEnding  +
                '"message" : "' + e.message + '",' + LineEnding;
        end;

        result := result + '"stacktrace": {' +
            '"exception_address" : "' + trim(BackTraceStrFunc(ExceptAddr)) + '",' + LineEnding +
            '"traces" : [';

        frames := ExceptFrames;
        len := ExceptFrameCount();
        for i := 0 to len - 1 do
        begin
            result := result + '"' + BackTraceStrFunc(frames[i]) + '"';
            if (i < len - 1) then
            begin
                result := result + ',' + LineEnding;
            end else
            begin
                result := result + LineEnding;
            end;
        end;
        result := result + ']' + LineEnding + '}' + LineEnding + '}';
    end;

    function TAjaxErrorHandler.handleError(
        const exc : Exception;
        const status : integer = 500;
        const msg : string  = 'Internal Server Error'
    ) : IErrorHandler;
    begin
        writeln('Content-Type: application/json');
        writeln('Status: ', intToStr(status), ' ', msg);
        writeln();
        writeln(getStackTrace(exc));
        result := self;
    end;
end.
