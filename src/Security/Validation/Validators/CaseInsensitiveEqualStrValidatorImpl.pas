{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit CaseInsensitiveEqualStrValidatorImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ReadOnlyListIntf,
    ValidatorIntf,
    RequestIntf,
    CompareStrValidatorImpl;

type

    (*!------------------------------------------------
     * basic class having capability to
     * validate data equality against a reference string
     * case insensitive
     * So 'Data' or 'DATA' will pass against ref string 'data'
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    TCaseInsensitiveEqualStrValidator = class(TCompareStrValidator)
    protected

        function compareStrWithRef(
            const astr: string;
            const refStr : string
        ) : boolean; override;
    public
        (*!------------------------------------------------
        * constructor
        *-------------------------------------------------*)
        constructor create(const refStr : string);
    end;

implementation

uses

    sysutils;

resourcestring

    sErrFieldMustBeCaseInsensitiveEqualStr = 'Field %s must be equal (case-insentive) to ';

    (*!------------------------------------------------
     * constructor
     *-------------------------------------------------*)
    constructor TCaseInsensitiveEqualStrValidator.create(const refStr : string);
    begin
        inherited create(sErrFieldMustBeCaseInsensitiveEqualStr + refStr);
        fRefStr := refStr;
    end;

    function TCaseInsensitiveEqualStrValidator.compareStrWithRef(
        const astr: string;
        const refStr : string
    ) : boolean;
    begin
        result := (lowercase(astr) = lowercase(refStr));
    end;

end.
