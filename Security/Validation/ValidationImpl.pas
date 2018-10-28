{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
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
        function validate(const request : IRequest) : boolean;

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

    KeyValueTypes;

type

    TValidatorRec = record
        validator : IValidator;
    end;
    PValidatorRec = ^TValidatorRec;

    constructor TValidation.create(const validators : IHashList);
    begin
        validatorList := validators;
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
     * @param keyvalue array of key value pair
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateKeyValue(const keyvalue : TArrayOfKeyValue) : boolean;
    var i, len : integer;
        valRec : PValidatorRec;
    begin
        result := true;
        len := length(keyvalue);
        for i:= 0 to len-1 do
        begin
            valRec := validatorList.find(keyvalue[i].key);
            //if valRec equals nil, it means there is no validation rule
            //registered for this key, so we assume validation always success
            if ((valRec <> nil) and
                (not valRec^.validator.isValid(keyvalue[i].value))) then
            begin
                result := false;
                exit();
            end;
        end;
    end;

    (*!------------------------------------------------
     * Validate data from request body
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateBody(const request : IRequest) : boolean;
    begin
        result := validateKeyValue(request.getParsedBodyParams());
    end;

    (*!------------------------------------------------
     * Validate data from request query string
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validateQueryStr(const request : IRequest) : boolean;
    begin
        result := validateKeyValue(request.getQueryParams());
    end;

    (*!------------------------------------------------
     * Validate data from request
     *-------------------------------------------------
     * @param request request instance to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TValidation.validate(const request : IRequest) : boolean;
    begin
        result := (validateBody(request) and validateQueryStr(request));
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
        valRec := validatorList.find(key);
        if (valRec = nil) then
        begin
            new(valRec);
            validatorList.add(key, valRec);
        end;
        valRec^.validator := validator;
        result := self;
    end;


end.