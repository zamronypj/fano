{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ValidationImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    RequestIntf,
    RequestValidatorintf,
    ValidationRulesIntf;

type

    (*!------------------------------------------------
     * basic validation class having capability to
     * validate input data from request instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TValidation = class(TInterfacedObject, IRequestValidator, IValidationRules, IDependency)
    private
        validationResult : TValidationResult;
        validatorList : IHashList;
        procedure clearValidator();
    public

        constructor create(const validators : IHashList);
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data from request
         *-------------------------------------------------
         * @param request request instance to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function validate(const request : IRequest) : TValidationResult;

        (*!------------------------------------------------
         * get last validation status result
         *-------------------------------------------------
         * @return validation result
         *-------------------------------------------------
         * This mechanism is provided to allow application doing
         * validation in middleware before controller and then
         * get validation result in controller/route handler
         * with assumption that it is same request validator
         * instance that is used in middleware and
         * controller/route handler.
         * IRequestValidator implementation must maintain
         * state of last validate() call result.
         *-------------------------------------------------*)
        function lastValidationResult() : TValidationResult;

        (*!------------------------------------------------
         * Add rule and its validator
         *-------------------------------------------------
         * @param key name of field in GET, POST request input data
         * @return current validation rules
         *-------------------------------------------------*)
        function addRule(const key : shortstring; const validator : IValidator) : IValidationRule;
    end;

implementation

uses

    KeyValueTypes,
    EInvalidValidatorImpl;

resourcestring

    sErrInvalidValidator = 'Validator for %s can not be nil';

type

    TValidatorRec = record
        key : shortstring;
        validator : IValidator;
    end;
    PValidatorRec = ^TValidatorRec;

    constructor TValidation.create(const validators : IHashList);
    begin
        validatorList := validators;
        validationResult.isValid := true;
        validationResult.errorMessages := nil;
    end;

    destructor TValidation.destroy();
    begin
        inherited destroy();
        clearValidator();
        validatorList := nil;
    end;

    procedure TValidation.clearValidator();
    var i, len : integer;
        valRec : PValidatorRec;
    begin
        len := validatorList.count();
        for i := len-1 downto 0 do
        begin
            valRec := validatorList.get(i);
            valRec^.validator := nil;
            dispose(valRec);
            validatorList.delete(i);
        end;
    end;

    (*!------------------------------------------------
     * Validate data from key value pair array
     *-------------------------------------------------
     * @param inputData array of key value pair
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateKeyValue(const inputData : IHashList) : TValidationResult;
    var i, len, numFailValidation : integer;
        valRec : PValidatorRec;
    begin
        result.isValid := true;
        len := validatorList.count();

        //assume all validator will fail
        setLength(result.errorMessages, len);
        numFailValidation := 0;
        for i:= 0 to len-1 do
        begin
            valRec := validatorList.get(i);
            if (not valRec^.validator.isValid(valRec^.key, inputData)) then
            begin
                //validation is failed, get validation error message
                with result.errorMessages[numFailValidation] do
                begin
                    key := valRec^.key;
                    errorMessage := valRec^.validator.errorMessage(valRec^.key);
                end;
                inc(numFailValidation);
                result.isValid := false;
            end;
        end;
        //set to actual number of failed validation
        setLength(result.errorMessages, numFailValidation);
    end;

    (*!------------------------------------------------
     * Validate data from request body
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateBody(const request : IRequest) : TValidationResult;
    begin
        result := validateKeyValue(request.getParsedBodyParams());
    end;

    (*!------------------------------------------------
     * Validate data from request query string
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateQueryStr(const request : IRequest) : TValidationResult;
    begin
        result := validateKeyValue(request.getQueryParams());
    end;

    (*!------------------------------------------------
     * Validate data from request
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validate(const request : IRequest)  : TValidationResult;
    var valResBody, valResQuery: TValidationResult;
        i, ctr, lenBody, lenQuery : integer;
    begin
        //merge validation result
        valResBody := validateBody(request);
        valResQuery := validateQueryStr(request);
        result.isValid := valResBody.isValid and valResQuery.isValid;
        lenBody:=length(valResBody.errorMessages);
        lenQuery:=length(valResQuery.errorMessages);
        setlength(result.errorMessages, lenBody + lenQuery);
        //TODO: can we improve by removing loop?
        ctr := 0;
        for i:=0 to lenBody-1 do
        begin
            result.errorMessage[ctr] := valResBody.errorMessages[i];
            inc(ctr);
        end;
        for i:=0 to lenQuery-1 do
        begin
            result.errorMessage[ctr] := valResQuery.errorMessages[i];
            inc(ctr);
        end;
        validationResult := result;
    end;

    (*!------------------------------------------------
     * get last validation status result
     *-------------------------------------------------
     * @return validation result
     *-------------------------------------------------*)
    function TValidation.lastValidationResult() : TValidationResult;
    begin
        result := validationResult;
    end;

    (*!------------------------------------------------
     * Add rule and its validator
     *-------------------------------------------------
     * @param key name of field in GET, POST request input data
     * @return current validation rules
     *-------------------------------------------------*)
    function addRule(const key : shortstring; const validator : IValidator) : IValidationRule;
    var valRec : PValidatorRec;
    begin
        if (validator = nil) then
        begin
            raise EInvalidValidator.createFmt(sErrInvalidValidator, [key]);
        end;

        valRec := validatorList.find(key);
        if (valRec = nil) then
        begin
            new(valRec);
            validatorList.add(key, valRec);
        end;
        valRec^.key := key;
        valRec^.validator := validator;
        result := self;
    end;


end.
