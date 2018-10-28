{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit AlphaNumValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RegexIntf,
    ValidatorIntf;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate input data using regex matching
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TRegexValidator = class(TInterfacedObject, IValidator)
    private
        regex : IRegex;
        regexPattern
    public
        constructor create(const regexInst : IRegex; const pattern : string);
        destructor destroy(); override;

        (*!------------------------------------------------
         * Validate data
         *-------------------------------------------------
         * @param dataToValidate data to validate
         * @return true if data is valid otherwise false
         *-------------------------------------------------*)
        function isValid(const dataToValidate : string) : boolean;
    end;

implementation

    constructor TRegexValidator.create(const regexInst : IRegex; const pattern : string);
    begin
        regex := regexInst;
        regexPattern := pattern;
    end;

    destructor TRegexValidator.destroy();
    begin
        inherited destroy();
        regex := nil;
    end;

    (*!------------------------------------------------
     * Validate data
     *-------------------------------------------------
     * @param dataToValidate data to validate
     * @return true if data is valid otherwise false
     *-------------------------------------------------*)
    function TRegexValidator.isValid(const dataToValidate : string) : boolean;
    begin
        result := regex.match(regexPattern, dataToValidate).matched;
    end;

end.