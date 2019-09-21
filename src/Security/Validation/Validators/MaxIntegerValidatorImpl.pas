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

    ListIntf,
    ValidatorIntf,
    RequestIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate if data does not greater than a reference value
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMaxIntegerValidator = class(TBaseValidator)
    private
        fMaximumValue : integer;
    protected
        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(
            const dataToValidate : string;
            const dataCollection : IList;
            const request : IRequest
        ) : boolean; override;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param maxValue maximum value allowed
         *-------------------------------------------------*)
        constructor create(const maxValue : integer);
    end;

implementation

uses

    SysUtils;

resourcestring

    sErrFieldMustBeIntegerWithMaxValue = 'Field %s must be integer with maximum value of ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TMaxIntegerValidator.create(const maxValue : integer);
    begin
        inherited create(sErrFieldMustBeIntegerWithMaxValue + intToStr(maxValue));
        fMaximumValue := maxValue;
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TMaxIntegerValidator.isValidData(
        const dataToValidate : string;
        const dataCollection : IList;
        const request : IRequest
    ) : boolean;
    var intValue : integer;
    begin
        result := tryStrToInt(dataToValidate, intValue) and (intValue <= fMaximumValue);
    end;
end.
