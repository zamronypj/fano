{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit DinersClubValidatorImpl;

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
     * that matched Diners Club credit card number pattern
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TDinersClubValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

const

    REGEX_DINERSCLUB = '^3(?:0[0-5]|[68][0-9])[0-9]{11}$';

resourcestring

    sErrNotValidDinersClubCreditCardNumber = 'Field ''%s'' must be Diners Club credit card number';

    constructor TDinersClubValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, REGEX_DINERSCLUB, sErrNotValidDinersClubCreditCardNumber);
    end;

end.
