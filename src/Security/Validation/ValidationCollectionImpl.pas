{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ValidationCollectionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    ValidatorCollectionIntf,
    RequestValidatorintf,
    InjectableObjectImpl;

type

    (*!------------------------------------------------
     * basic validation class having capability to
     * validate input data from request instance
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TValidationCollection = class(TInjectableObject, IValidatorCollection)
    private
        requestValidatorList : IList;
        procedure clearValidator();
    public

        constructor create(const reqValidators : IList);
        destructor destroy(); override;

        (*!------------------------------------------------
         * Add request validator to collection
         *-------------------------------------------------
         * @param name name of request validator
         * @param validator request validator instance to add
         * @return current validator collection
         *-------------------------------------------------*)
        function add(const name : shortstring; const validator : IRequestValidator) : IValidatorCollection;

        (*!------------------------------------------------
         * get request validator by name
         *-------------------------------------------------
         * @param name name of request validator
         * @return request validator instance
         *-------------------------------------------------*)
        function get(const name : shortstring) : IRequestValidator;
    end;

implementation

uses

    EInvalidValidatorImpl;

resourcestring

    sErrInvalidRequestValidator = 'Request validator for %s can not be nil';
    sErrRequestValidatorNotFound = 'Request validator %s not found';

type

    TValidatorRec = record
        key : shortstring;
        validator : IRequestValidator;
    end;
    PValidatorRec = ^TValidatorRec;

    constructor TValidationCollection.create(const reqValidators : IList);
    begin
        requestValidatorList := reqValidators;
    end;

    destructor TValidationCollection.destroy();
    begin
        clearValidator();
        requestValidatorList := nil;
        inherited destroy();
    end;

    procedure TValidationCollection.clearValidator();
    var i, len : integer;
        valRec : PValidatorRec;
    begin
        len := requestValidatorList.count();
        for i := len-1 downto 0 do
        begin
            valRec := requestValidatorList.get(i);
            valRec^.validator := nil;
            dispose(valRec);
            validatorList.delete(i);
        end;
    end;

    (*!------------------------------------------------
     * Add rule and its validator
     *-------------------------------------------------
     * @param key name of field in GET, POST request input data
     * @return current validation rules
     *-------------------------------------------------*)
    function TValidationCollection.add(const name : shortstring; const validator : IRequestValidator) : IValidationCollection;
    var valRec : PValidatorRec;
    begin
        if (validator = nil) then
        begin
            raise EInvalidValidator.createFmt(sErrInvalidRequestValidator, [name]);
        end;

        valRec := requestValidatorList.find(name);
        if (valRec = nil) then
        begin
            new(valRec);
            requestValidatorList.add(name, valRec);
        end;
        valRec^.key := key;
        valRec^.validator := validator;
        result := self;
    end;

    (*!------------------------------------------------
     * get request validator by name
     *-------------------------------------------------
     * @param name name of request validator
     * @return request validator instance
     *-------------------------------------------------*)
    function TValidationCollection.get(const name : shortstring) : IRequestValidator;
    var valRec : PValidatorRec;
    begin
        valRec := requestValidatorList.find(name);
        if (valRec = nil) then
        begin
            raise EInvalidValidator.createFmt(sErrRequestValidatorNotFound, [name]);
        end;
        if (valRec^.validator = nil) then
        begin
            raise EInvalidValidator.createFmt(sErrInvalidRequestValidator, [name]);
        end;
        result := valRec^.validator;
    end;

end.
