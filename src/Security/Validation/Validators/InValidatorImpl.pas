{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit InValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    SysUtils,
    ReadOnlyListIntf,
    ValidatorIntf,
    RequestIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate data that must included in given list of values
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TInValidator = class(TBaseValidator)
    protected
        fValidValues : TStringArray;

        (*!------------------------------------------------
         * actual data validation
         *-------------------------------------------------
         * @param dataToValidate input data
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValidData(
            const dataToValidate : string;
            const dataCollection : IReadOnlyList;
            const request : IRequest
        ) : boolean; override;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------*)
        constructor create(const validValues : array of string);

        (*!------------------------------------------------
         * destructor
         *-------------------------------------------------*)
        destructor destroy(); override;
    end;

implementation

resourcestring

    sErrFieldMustBeIn = 'Field %%s must be in given values "%s"';

    function initValidValues(const validValues : array of string) : TStringArray;
    var i, tot : integer;
    begin
        tot := high(validValues) - low(validValues) + 1;
        setLength(result, tot);
        for i := 0 to tot-1 do
        begin
            result[i] := validValues[i];
        end;
    end;

    function asCommaSeparatedStr(const validValues : array of string) : string;
    var i, tot : integer;
    begin
        tot := high(validValues) - low(validValues) + 1;
        result := '';
        for i := 0 to tot-2 do
        begin
            result := result + '"' + validValues[i] + '", ';
        end;
        result := result + validValues[tot-1];
    end;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TInValidator.create(const validValues : array of string);
    begin
        inherited create(
            format(
                sErrFieldMustBeIn,
                [ asCommaSeparatedStr(validValues) ]
            )
        );
        fValidValues := initValidValues(validValues);
    end;

    (*!------------------------------------------------
     * destructor
     *-------------------------------------------------*)
    destructor TInValidator.destroy();
    begin
        setLength(fValidValues, 0);
        inherited destroy();
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TInValidator.isValidData(
        const dataToValidate : string;
        const dataCollection : IReadOnlyList;
        const request : IRequest
    ) : boolean;
    var i, len : integer;
    begin
        result := false;
        len := length(fValidValues);
        for i := 0 to len - 1 do
        begin
            if (dataToValidate = fValidValues[i]) then
            begin
                result := true;
                exit();
            end;
        end;
    end;
end.
