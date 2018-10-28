{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit IntegerValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ValidatorIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate alpha numeric input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TIntegerValidator = class(TInterfacedObject, IValidator)
    public
        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param dataToValidate data to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(const dataToValidate : string) : boolean;
    end;

implementation

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TIntegerValidator.isValid(const dataToValidate : string) : boolean;
    begin
        try
            dataToValidate.toInteger();
            result := true;
        except
            result := false;
        end;
    end;

end.