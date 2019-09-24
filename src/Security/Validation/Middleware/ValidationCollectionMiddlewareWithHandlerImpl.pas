{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ValidationCollectionMiddlewareWithHandlerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    RequestIntf,
    ResponseIntf,
    RequestValidatorIntf,
    ValidatorCollectionIntf,
    MiddlewareIntf,
    RequestHandlerIntf,
    RouteArgsReaderIntf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic validation class having capability to
     * validate input data from request instance and display
     * custom validation error response
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TValidationCollectionMiddlewareWithHandler = class(TInjectableObject, IMiddleware)
    private
        fValidation : IValidatorCollection;
        fValidationErrorHandler : IRequestHandler;
    public
        constructor create(
            const validationInst : IValidatorCollection;
            const validationErrorHandler : IRequestHandler
        );
        destructor destroy(); override;

        (*!---------------------------------------
         * handle request and validate request
         *----------------------------------------
         * @param request request instance
         * @param response response instance
         * @param route arguments
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
            const args : IRouteArgsReader;
            var canContinue : boolean
        ) : IResponse;

    end;

implementation


    constructor TValidationCollectionMiddlewareWithHandler.create(
        const validationInst : IValidatorCollection;
        const validationErrorHandler : IRequestHandler
    );
    begin
        fValidation := validationInst;
        fValidationErrorHandler := validationErrorHandler;
    end;

    destructor TValidationCollectionMiddlewareWithHandler.destroy();
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
     * @param route arguments
     * @param canContinue return true if execution
     *        can continue to next middleware or false
     *        to stop execution
     * @return response
     *----------------------------------------*)
    function TValidationCollectionMiddlewareWithHandler.handleRequest(
        const request : IRequest;
        const response : IResponse;
        const args : IRouteArgsReader;
        var canContinue : boolean
    ) : IResponse;
    var requestValidator : IRequestValidator;
    begin
        requestValidator := fValidation.get(args.getName());
        canContinue := requestValidator.validate(request).isValid;
        if (canContinue) then
        begin
            result := response;
        end else
        begin
            //validation failed, let validation error handler take care
            result := fValidationErrorHandler.handleRequest(request, response, args);
        end;
    end;

end.
