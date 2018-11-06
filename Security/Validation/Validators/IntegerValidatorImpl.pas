{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit IntegerValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ValidatorIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate alpha numeric input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TIntegerValidator = class(TBaseValidator)
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------*)
        constructor create();

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
    end;

implementation

uses

    KeyValueTypes;

resourcestring

    sErrFieldMustBeInteger = 'Field %s must be integer value';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TIntegerValidator.create();
    begin
        inherited create(sErrFieldMustBeInteger);
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TIntegerValidator.isValid(
        const key : shortstring;
        const dataToValidate : IHashList
    ) : boolean;
    var val : PKeyValueType;
    begin
        val := dataToValidate.find(key);
        if (val = nil) then
        begin
            //if we get here it means there is no field with that name
            //so assume that validation is success
            result := true;
        end;

        try
            val^.value.toInteger();
            result := true;
        except
            //if we get here, mostly because of EConvertError exception
            //so assume it is not valid integer.
            result := false;
        end;
    end;
end.
