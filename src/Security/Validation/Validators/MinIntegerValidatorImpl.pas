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
        fMinimumValue : integer;
    protected
        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(var dataToValidate : string) : boolean; override;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param minValue minimum value allowed
         *-------------------------------------------------*)
        constructor create(const minValue : integer);
    end;

implementation

uses

    SysUtils;

resourcestring

    sErrFieldMustBeIntegerWithMinValue = 'Field %s must be integer with minimum value of ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TMinIntegerValidator.create(const minValue : integer);
    begin
        inherited create(sErrFieldMustBeIntegerWithMinValue + intToStr(minValue));
        fMinimumValue := minValue;
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TMinIntegerValidator.isValidData(const dataToValidate : string) : boolean;
    var intValue : integer;
    begin
        result := tryStrToInt(dataToValidate, intValue) and (intValue >= fMinimumValue);
    end;
end.
