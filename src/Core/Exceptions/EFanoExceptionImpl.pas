{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EFanoExceptionImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sysutils;

type

    (*!------------------------------------------------
     * Base exception that add additional header line.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    EFanoException = class(Exception)
    private
        fHeader : string;
        fStatus : integer;
    public
        constructor create(
            const errMsg : string;
            const statusCode : integer = 500;
            const additionalHeader : string = ''
        );

        property status : integer read fStatus;
        property header : string read fHeader;
    end;

implementation

    constructor EFanoException.create(
        const errMsg : string;
        const statusCode : integer = 500;
        const additionalHeader : string = ''
    );
    begin
        inherited create(errMsg);
        fStatus := statusCode;
        fHeader := additionalHeader;
    end;

end.
