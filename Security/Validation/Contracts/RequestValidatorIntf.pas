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

    RequestIntf,
    ValidationResultTypes;

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
         * @return validation result
         *-------------------------------------------------*)
        function validate(const request : IRequest) : TValidationResult;

        (*!------------------------------------------------
         * get last validation status result
         *-------------------------------------------------
         * @return validation result
         *-------------------------------------------------
         * This mechanism is provided to allow application doing
         * validation in middleware before controller is exceuted
         * and then get validation result in controller/route handler
         * if course with assumption that it is same request validator
         * instance that is shared between middleware and
         * controller/route handler.
         * IRequestValidator implementation must maintain
         * state of last validate() call result.
         *-------------------------------------------------*)
        function lastValidationResult() : TValidationResult;
    end;

implementation



end.
