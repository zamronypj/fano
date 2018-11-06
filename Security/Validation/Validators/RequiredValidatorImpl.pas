{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RequiredValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    HashListIntf,
    ValidatorIntf,
    BaseValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate required input data, i.e, data that must
     * be present and not empty
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRequiredValidator = class(TBaseValidator)
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

    sErrFieldIsRequired = 'Field %s is required and not empty';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TRequiredValidator.create();
    begin
        inherited create(sErrFieldIsRequired);
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param key name of field
     * @param dataToValidate input data
     * @return true if data is valid otherwise false
     *-------------------------------------------------
     * We assume dataToValidate <> nil
     *-------------------------------------------------*)
    function TRequiredValidator.isValid(
        const key : shortstring;
        const dataToValidate : IHashList
    ) : boolean;
    var val : PKeyValueType;
    begin
        val := dataToValidate.find(key);
        result := (val <> nil) and (length(val^.value) > 0);
    end;

end.
