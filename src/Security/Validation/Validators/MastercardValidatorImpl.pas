{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit MastercardValidatorImpl;

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
     * that matched Mastercard credit card number pattern
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TMastercardValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

const

    REGEX_MASTERCARD = '^5[1-5][0-9]{14}$|' +
        '^2(?:2(?:2[1-9]|[3-9][0-9])|[3-6][0-9][0-9]|7(?:[01][0-9]|20)[0-9]{12}$';

resourcestring

    sErrNotValidMastercardCreditCardNumber = 'Field ''%s'' must be Mastercard credit card number';

    constructor TMastercardValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, REGEX_MASTERCARD, sErrNotValidMastercardCreditCardNumber);
    end;

end.
