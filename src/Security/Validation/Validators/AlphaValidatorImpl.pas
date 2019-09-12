{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AlphaValidatorImpl;

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
     * validate alphabet character input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAlphaValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

resourcestring

    sErrNotValidAlpha = 'Field ''%s'' must be alphabet characters';

    constructor TAlphaValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, '^[a-zA-Z]+$', sErrNotValidAlpha);
    end;

end.
