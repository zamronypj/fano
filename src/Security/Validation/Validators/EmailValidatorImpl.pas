{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EmailValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RegexIntf,
    ValidatorIntf,
    RegexValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate email input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TEmailValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

resourcestring

    sErrNotValidEmail = 'Field ''%s'' must be email format';

    constructor TEmailValidator.create(const regexInst : IRegex);
    begin
        inherited create(
            regexInst,
            '^[_a-zA-Z\d\-.]+@([a-zA-Z\d\-]+(\.[_a-zA-Z\d\-]+)*)$',
            sErrNotValidEmail
        );
    end;

end.
