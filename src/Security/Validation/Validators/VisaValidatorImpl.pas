{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit VisaValidatorImpl;

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
     * that matched VISA credit card number pattern
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TVisaValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

const

    REGEX_VISA = '^4[0-9]{12}(?:[0-9]{3})?$';

resourcestring

    sErrNotValidVisaCreditCardNumber = 'Field ''%s'' must be VISA credit card number';

    constructor TVisaValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, REGEX_VISA, sErrNotValidVisaCreditCardNumber);
    end;

end.
