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

    ListIntf,
    RequestIntf,
    ValidatorIntf,
    BaseCompositeValidatorImpl,
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
    TCompositeValidator = class(TBaseCompositeValidator)
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
    function TCompositeValidator.isValid(
        const key : shortstring;
        const dataToValidate : IList;
        const request : IRequest
    ) : boolean;
    var i, len : integer;
    begin
        result := true;
        len := length(fValidators);
        for i := 0 to len - 1 do
        begin
            if (not fValidators[i].isValid(key, dataToValidate, request)) then
            begin
                result := false;
                errorMsgFormat := fValidators[i].errorMessage(key);
                exit();
            end;
        end;
    end;
end.
