{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ValidatorIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    HashListIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * validate input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IValidator = interface
        ['{CEC67097-2D57-4278-BE8F-7B77EAB614FB}']

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
        ) : boolean;

        (*!------------------------------------------------
         * Get validation error message
         *-------------------------------------------------
         * @param key name of filed that is being validated
         * @return validation error message
         *-------------------------------------------------*)
        function errorMessage(const key : shortstring) : string;
    end;

implementation



end.
