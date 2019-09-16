{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CollectiveValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    RequestIntf,
    ValidatorIntf,
    BaseValidatorImpl,
    ValidatorArrayTypes;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate data using one or more validator
     * This is provided to allow complex validation using
     * several simple validator
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *------------------------------------------------*)
    TCollectiveValidator = class(TBaseCompositeValidator)
    public
        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param key name of field
         * @param dataToValidate input data
         * @param request request object
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(
            const key : shortstring;
            const dataToValidate : IList;
            const request : IRequest
        ) : boolean; override;

    end;

implementation


    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TCollectiveValidator.isValid(
        const key : shortstring;
        const dataToValidate : IList;
        const request : IRequest
    ) : boolean;
    var i, len : integer;
    begin
        result := true;
        len := length(fValidators);
        errorMsgFormat := '';
        for i := 0 to len - 1 do
        begin
            if (not fValidators[i].isValid(key, dataToValidate, request)) then
            begin
                result := false;
                errorMsgFormat := errorMsgFormat + ', ' + fValidators[i].errorMessage(key);
            end;
        end;
    end;
end.