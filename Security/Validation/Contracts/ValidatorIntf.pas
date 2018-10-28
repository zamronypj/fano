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
         * @param dataToValidate data to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(const dataToValidate : string) : boolean;
    end;

implementation



end.