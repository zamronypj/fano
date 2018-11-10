{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit HtmlAjaxErrorHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SysUtils,
    RequestIntf,
    ErrorHandlerIntf,
    BaseErrorHandlerImpl;

type

    (*!---------------------------------------------------
     * composite error handler that display error as JSON
     * for ajax request or as html response for other
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *---------------------------------------------------*)
    THtmlAjaxErrorHandler = class(TBaseErrorHandler)
    private
        request : IRequest;
        ajaxErrorHandler : IErrorHandler;
        htmlErrorHandler : IErrorHandler;
    public
        (*!---------------------------------------------------
         * constructor
         *----------------------------------------------------
         * @param requestInst request instance
         * @param ajaxErrorHandler error handler for ajax request
         * @param htmlErrorHandler error handler for other request
         *---------------------------------------------------*)
        constructor create(
            const requestInst : IRequest;
            const ajaxErrHandler : IErrorHandler;
            const htmlErrHandler : IErrorHandler
        );

        (*!---------------------------------------------------
         * destructor
         *---------------------------------------------------*)
        destructor destroy(); override;

        (*!---------------------------------------------------
         * handle exception
         *----------------------------------------------------
         * @param exc exception that is to be handled
         * @param status HTTP error status, default is HTTP error 500
         * @param msg HTTP error message
         *---------------------------------------------------*)
        function handleError(
            const exc : Exception;
            const status : integer = 500;
            const msg : string  = 'Internal Server Error'
        ) : IErrorHandler; override;
    end;

implementation

    (*!---------------------------------------------------
     * constructor
     *----------------------------------------------------
     * @param request request instance
     * @param ajaxErrorHandler error handler for ajax request
     * @param htmlErrorHandler error handler for other request
     *---------------------------------------------------*)
    constructor THtmlAjaxErrorHandler.create(
        const requestInst : IRequest;
        const ajaxErrHandler : IErrorHandler;
        const htmlErrHandler : IErrorHandler
    );
    begin
        request := requestInst;
        ajaxErrorHandler := ajaxErrHandler;
        htmlErrorHandler := htmlErrHandler;
    end;

    destructor THtmlAjaxErrorHandler.destroy();
    begin
        inherited destroy();
        request := nil;
        ajaxErrorHandler := nil;
        htmlErrorHandler := nil;
    end;

    (*!---------------------------------------------------
     * handle exception
     *----------------------------------------------------
     * @param exc exception that is to be handled
     * @param status HTTP error status, default is HTTP error 500
     * @param msg HTTP error message
     *---------------------------------------------------*)
    function THtmlAjaxErrorHandler.handleError(
        const exc : Exception;
        const status : integer = 500;
        const msg : string  = 'Internal Server Error'
    ) : IErrorHandler;
    var errHandler : IErrorHandler;
    begin
        if (request.isXhr()) then
        begin
            errHandler := ajaxErrorHandler;
        end else
        begin
            errHandler := htmlErrorHandler;
        end;
        errHandler.handleError(exc, status, msg);
        result := self;
    end;
end.
