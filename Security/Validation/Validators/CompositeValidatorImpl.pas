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

    classes,
    HashListIntf,
    ValidatorIntf,
    ValidatorCollectionIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate data using one or more validator
     * This is provided to allow complex validation using
     * several simple validator
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TCompositeValidator = class(TBaseValidator, IValidatorCollection)
    private
        validatorList : TInterfaceList;
    public
        constructor create(const errMsgFormat : string);
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param key name of field
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
         function isValid(
             const key : shortstring;
             const dataToValidate : IHashList
         ) : boolean; override;

        (*!------------------------------------------------
         * Add validator to collection
         *-------------------------------------------------
         * @param validator validator instance to add
         * @return current validator collection
         *-------------------------------------------------*)
        function add(const validator : IValidator) : IValidatorCollection;

        (*!------------------------------------------------
         * get number of validator in collection
         *-------------------------------------------------
         * @return current validator collection
         *-------------------------------------------------*)
        function count() : integer;

        (*!------------------------------------------------
         * get validator by index
         *-------------------------------------------------
         * @return validator instance
         *-------------------------------------------------*)
        function get(const indx : integer) : IValidator;
    end;

implementation

    constructor TCompositeValidator.create(const errMsgFormat : string);
    begin
        inherited create(errMsgFormat);
        validatorList := TInterfaceList.create();
    end;

    destructor TCompositeValidator.destroy();
    begin
        inherited destroy();
        validatorList.free();
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TCompositeValidator.isValid(
        const key : shortstring;
        const dataToValidate : IHashList
    ) : boolean;
    var i, len : integer;
        validator : IValidator;
    begin
        result := true;
        len := count();
        for i := 0 to len-1 do
        begin
            validator := get(i);
            if (not validator.isValid(key, dataToValidate)) then
            begin
                result := false;
                exit();
            end;
        end;
    end;

    (*!------------------------------------------------
     * Add validator to collection
     *-------------------------------------------------
     * @param validator validator instance to add
     * @return current validator collection
     *-------------------------------------------------*)
    function TCompositeValidator.add(const validator : IValidator) : IValidatorCollection;
    begin
        validatorList.add(validator);
        result := self;
    end;

    (*!------------------------------------------------
     * get number of validator in collection
     *-------------------------------------------------
     * @return current validator collection
     *-------------------------------------------------*)
    function TCompositeValidator.count() : integer;
    begin
        result := validatorList.count;
    end;

    (*!------------------------------------------------
     * get validator by index
     *-------------------------------------------------
     * @return validator instance
     *-------------------------------------------------*)
    function TCompositeValidator.get(const indx : integer) : IValidator;
    begin
        result := validatorList[indx] as IValidator;
    end;
end.
