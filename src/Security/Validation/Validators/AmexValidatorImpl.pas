{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AmexValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RegexIntf,
    ValidatorIntf,
    RegexValidatorImpl;

type

    (*!------------------------------------------------
     * class having capability to validate input data
     * that matched American Express credit card number pattern
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAmexValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

const

    REGEX_AMEX = '^3[47][0-9]{13}$';

resourcestring

    sErrNotValidAmexCreditCardNumber = 'Field ''%s'' must be American Express credit card number';

    constructor TAmexValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, REGEX_AMEX, sErrNotValidAmexCreditCardNumber);
    end;

end.
