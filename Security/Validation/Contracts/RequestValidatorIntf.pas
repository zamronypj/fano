{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit RequestValidatorIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    RequestIntf;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * validate input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IRequestValidator = interface
        ['{6CB55A49-DD2F-48C3-A95C-58808E11BFAB}']

        (*!------------------------------------------------
         * Validate data from request
         *-------------------------------------------------
         * @param request request instance to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function validate(const request : IRequest) : boolean;
    end;

implementation



end.