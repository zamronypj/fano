{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CompositeValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    RequestIntf,
    ValidatorIntf,
    BaseValidatorImpl;

type

    TValidatorArray = array of IValidator;

    (*!------------------------------------------------
     * basic class having capability to
     * validate data using one or more validator
     * This is provided to allow complex validation using
     * several simple validator
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TCompositeValidator = class(TBaseValidator)
    private
        fValidators : TValidatorArray;
    protected
        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(const dataToValidate : string) : boolean; override;
    public
        constructor create(const avalidators : array of IValidator);
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param key name of field
         * @param dataToValidate input data
         * @param request request object
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
         function isValid(
             const key : shortstring;
             const dataToValidate : IList;
            const request : IRequest
         ) : boolean; override;

    end;

implementation

    function initValidators(const avalidators : array of IValidator) : TValidatorArray;
    var i, len : integer;
    begin
        len := high(avalidators) - low(avalidators) + 1;
        setLength(result, len);
        for i := 0 to len -1 do
        begin
            result[i] := avalidators[i];
        end;
    end;

    function freeValidators(const validators : TValidatorArray) : TValidatorArray;
    var i, len : integer;
    begin
        len := length(validators);
        for i := 0 to len -1 do
        begin
            result[i] := nil;
        end;
        setLength(result, 0);
        result := nil;
    end;

    constructor TCompositeValidator.create(const avalidators : array of IValidator);
    begin
        //just set empty error string. We will get from external validators
        inherited create('');
        fValidators := initValidators(avalidators);
    end;

    destructor TCompositeValidator.destroy();
    begin
        fValidators := freeValidators(fValidators);
        inherited destroy();
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TCompositeValidator.isValidData(const dataToValidate : string) : boolean;
    begin
        //intentionally always pass validation
        //because we delegate validation to external validators
        result := true;
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TCompositeValidator.isValid(
        const key : shortstring;
        const dataToValidate : IList;
        const request : IRequest
    ) : boolean;
    var i, len : integer;
    begin
        result := true;
        len := length(fValidators);
        for i := 0 to len-1 do
        begin
            if (not fValidators[i].isValid(key, dataToValidate, request)) then
            begin
                result := false;
                errorMsgFormat := fValidators[i].errorMessage(key);
                exit();
            end;
        end;
    end;
end.
