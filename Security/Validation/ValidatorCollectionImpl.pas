{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ValidatorCollectionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    classes,
    ValidatorIntf,
    ValidatorCollectionIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * manage validator instances and validate data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TValidatorCollection = class(TInterfacedObject, IValidatorCollection, IValidator)
    private
        validatorList : TInterfaceList;
    public
        constructor create();
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param dataToValidate data to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(const dataToValidate : string) : boolean;

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

    constructor TValidatorCollection.create();
    begin
        validatorList := TInterfaceList.create();
    end;

    destructor TValidatorCollection.destroy();
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
    function TValidatorCollection.isValid(const dataToValidate : string) : boolean;
    var i, len : integer;
        validator : IValidator;
    begin
        result := true;
        len := count();
        for i := 0 to len-1 do
        begin
            validator := get(i);
            if (not validator.isValid(dataToValidate)) then
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
    function TValidatorCollection.add(const validator : IValidator) : IValidatorCollection;
    begin
        validatorList.add(validator);
    end;

    (*!------------------------------------------------
     * get number of validator in collection
     *-------------------------------------------------
     * @return current validator collection
     *-------------------------------------------------*)
    function TValidatorCollection.count() : integer;
    begin
        result := validatorList.count;
    end;

    (*!------------------------------------------------
     * get validator by index
     *-------------------------------------------------
     * @return validator instance
     *-------------------------------------------------*)
    function TValidatorCollection.get(const indx : integer) : IValidator;
    begin
        result := validatorList[indx] as IValidator;
    end;

end.