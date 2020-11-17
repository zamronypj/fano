{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DiscoverValidatorImpl;

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
     * that matched Discover credit card number pattern
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TDiscoverValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

const

    REGEX_DISCOVER = '^65[4-9][0-9]{13}|64[4-9][0-9]{13}|6011[0-9]{12}|' +
        '(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10})$';

resourcestring

    sErrNotValidDiscoverCreditCardNumber = 'Field ''%s'' must be Discover credit card number';

    constructor TDiscoverValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, REGEX_DISCOVER, sErrNotValidDiscoverCreditCardNumber);
    end;

end.
