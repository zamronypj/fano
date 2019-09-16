{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ValidationMiddlewareWithHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    RequestIntf,
    ResponseIntf,
    RequestValidatorintf,
    MiddlewareIntf,
    RequestHandlerIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic validation class having capability to
     * validate input data from request instance and display
     * custom validation error response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TValidationMiddlewareWithHandler = class(TInjectableObject, IMiddleware)
    private
        fValidation : IRequestValidator;
        fValidationErrorHandler : IRequestHandler;
    public
        constructor create(
            const validationInst : IRequestValidator;
            const validationErrorHandler : IRequestHandler
        );
        destructor destroy(); override;

        (*!---------------------------------------
         * handle request and validate request
         *----------------------------------------
         * @param request request instance
         * @param response response instance
         * @param canContinue return true if execution
         *        can continue to next middleware or false
         *        to stop execution
         * @return response
         *----------------------------------------
         * Status of validation result will be store
         * in request with attribute name 'validation'
         *----------------------------------------*)
        function handleRequest(
            const request : IRequest;
            const response : IResponse;
            var canContinue : boolean
        ) : IResponse;

    end;

implementation


    constructor TValidationMiddlewareWithHandler.create(
        const validationInst : IRequestValidator;
        const validationErrorHandler : IRequestHandler
    );
    begin
        fValidation := validationInst;
        fValidationErrorHandler := validationErrorHandler;
    end;

    destructor TValidationMiddlewareWithHandler.destroy();
    begin
        fValidation := nil;
        fValidationErrorHandler := nil;
        inherited destroy();
    end;

    (*!---------------------------------------
     * handle request
     *----------------------------------------
     * @param request request instance
     * @param response response instance
     * @param canContinue return true if execution
     *        can continue to next middleware or false
     *        to stop execution
     * @return response
     *----------------------------------------*)
    function TValidationMiddlewareWithHandler.handleRequest(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    begin
        canContinue := fValidation.validate(request).isValid;
        if (canContinue) then
        begin
            result := response;
        end else
        begin
            //validation failed, let validation error handler take care
            result := fValidationErrorHandler.handleRequest(request, response);
        end;
    end;

end.
