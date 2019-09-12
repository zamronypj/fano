{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit UuidValidatorImpl;

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
     * validate uuid data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TUuidValidator = class(TBaseValidator)
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
         *-------------------------------------------------*)
        constructor create();
    end;

implementation

uses

    SysUtils;

resourcestring

    sErrFieldMustBeUuid = 'Field %s must be UUID value';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TUuidValidator.create();
    begin
        inherited create(sErrFieldMustBeUuid);
    end;

    (*!------------------------------------------------
     * actual data validation
     *-------------------------------------------------
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TUuidValidator.isValidData(const dataToValidate : string) : boolean;
    var actualVal : TGUID;
    begin
        //try to convert string to uuid
        result := tryStrToGuid(dataToValidate, actualVal);
    end;
end.
