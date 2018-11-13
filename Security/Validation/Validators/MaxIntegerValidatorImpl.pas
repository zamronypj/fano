{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MaxIntegerValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ValidatorIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate if data does not less than a reference value
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMaxIntegerValidator = class(TBaseValidator)
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param maxValue maximum value allowed
         *-------------------------------------------------*)
        constructor create(const maxValue : integer);

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

    sErrFieldMustBeIntegerWithMaxValue = 'Field %s must be integer with maximum value of ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TMaxIntegerValidator.create(const maxValue : integer);
    begin
        inherited create(sErrFieldMustBeIntegerWithMaxValue + intToStr(maxValue));
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TMaxIntegerValidator.isValid(
        const key : shortstring;
        const dataToValidate : IHashList
    ) : boolean;
    var val : PKeyValueType;
        intValue : integer;
    begin
        val := dataToValidate.find(key);
        if (val = nil) then
        begin
            //if we get here it means there is no field with that name
            //so assume that validation is success
            result := true;
        end;

        try
            intValue := val^.value.toInteger();
            result := (intValue <= maxValue);
        except
            //if we get here, mostly because of EConvertError exception
            //so assume it is not valid integer.
            result := false;
        end;
    end;
end.
