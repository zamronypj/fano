{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit AlphaNumValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ValidatorIntf,
    RegexValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate alpha numeric space input data
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TAlphaNumSpaceValidator = class(TRegexValidator)
    public
        constructor create(const regexInst : IRegex);
    end;

implementation

resourcestring

    sErrNotValidAlphaNumSpace = 'Field %s must be alpha numeric whitespace characters';

    constructor TAlphaNumSpaceValidator.create(const regexInst : IRegex);
    begin
        inherited create(regexInst, '^[a-zA-Z0-9\s]+$', sErrNotValidAlphaNumSpace);
    end;

end.
