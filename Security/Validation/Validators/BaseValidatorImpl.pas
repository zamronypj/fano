{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BaseValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ListIntf,
    ValidatorIntf;

type

    (*!------------------------------------------------
     * base abstract class having capability to
     * validate input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TBaseValidator = class(TInterfacedObject, IValidator)
    private
        errorMsgFormat : string;
    public
        (*!------------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param errMsgFormat message that is used as template
         *                    for error message
         *-------------------------------------------------
         * errMsgFormat can use format that is support by
         * SysUtils.Format() function
         *-------------------------------------------------*)
        constructor create(const errMsgFormat : string);

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
         ) : boolean; virtual; abstract;

        (*!------------------------------------------------
         * Get validation error message
         *-------------------------------------------------
         * @param key name of filed that is being validated
         * @return validation error message
         *-------------------------------------------------*)
        function errorMessage(const key : shortstring) : string;
    end;

implementation

uses

    sysutils;

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param regexInst instance of IRegex
     * @param pattern regex pattern to use for matching
     * @param errMsgFormat message that is used as template
     *                    for error message
     *-------------------------------------------------
     * errMsgFormat can use format that is support by
     * SysUtils.Format() function
     *-------------------------------------------------*)
    constructor TBaseValidator.create(const errMsgFormat : string);
    begin
        errorMsgFormat := errMsgFormat;
    end;

    (*!------------------------------------------------
     * Get validation error message
     *-------------------------------------------------
     * @return validation error message
     *-------------------------------------------------*)
    function TBaseValidator.errorMessage(const key : shortstring) : string;
    begin
        result := format(errorMsgFormat, [key]);
    end;
end.
