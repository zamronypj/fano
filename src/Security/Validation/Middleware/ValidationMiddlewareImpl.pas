{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ValidationMiddlewareImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    RequestIntf,
    ResponseIntf,
    RequestValidatorintf,
    MiddlewareIntf;

type

    (*!------------------------------------------------
     * basic validation class having capability to
     * validate input data from request instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TValidationMiddleware = class(TInterfacedObject, IMiddleware, IDependency)
    private
        validation : IRequestValidator;
    public
        constructor create(const validationInst : IRequestValidator);
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

uses

    ValidationResultTypes;

    constructor TValidationMiddleware.create(const validationInst : IRequestValidator);
    begin
        validation := validationInst;
    end;

    destructor TValidationMiddleware.destroy();
    begin
        inherited destroy();
        validation := nil;
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
    function TValidationMiddleware.handleRequest(
        const request : IRequest;
        const response : IResponse;
        var canContinue : boolean
    ) : IResponse;
    begin
        validation.validate(request);
        result := response;
    end;

end.
