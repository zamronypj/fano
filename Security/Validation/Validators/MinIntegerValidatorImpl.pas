{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MinIntegerValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    ValidatorIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate if data does not less than a reference value
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMinIntegerValidator = class(TBaseValidator)
    private
        minimumValue : integer;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param minValue minimum value allowed
         *-------------------------------------------------*)
        constructor create(const minValue : integer);

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param key name of field
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
         function isValid(
             const key : shortstring;
             const dataToValidate : IList
         ) : boolean; override;
    end;

implementation

uses

    SysUtils,
    KeyValueTypes;

resourcestring

    sErrFieldMustBeIntegerWithMinValue = 'Field %s must be integer with minimum value of ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TMinIntegerValidator.create(const minValue : integer);
    begin
        inherited create(sErrFieldMustBeIntegerWithMinValue + intToStr(minValue));
        minimumValue := minValue;
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TMinIntegerValidator.isValid(
        const key : shortstring;
        const dataToValidate : IList
    ) : boolean;
    var val : PKeyValue;
        intValue : integer;
    begin
        val := dataToValidate.find(key);
        if (val = nil) then
        begin
            //if we get here it means there is no field with that name
            //so assume that validation is success
            result := true;
            exit();
        end;

        try
            intValue := strToInt(val^.value);
            result := (intValue >= minimumValue);
        except
            //if we get here, mostly because of EConvertError exception
            //so assume it is not valid integer.
            result := false;
        end;
    end;
end.
