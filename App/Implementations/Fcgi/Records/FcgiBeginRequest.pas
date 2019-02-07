{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiBeginRequest;

interface

{$MODE OBJFPC}
{$H+}

type

    TFcgiBeginRequest = class(TFcgiRecord)
    private
        fRole : byte;
        fFlags : byte;
        fReserved1 : shortstring;
    public
        constructor create();
        constructor create(
            const role : byte;
            const flag: byte;
            const reserved1 : shortstring
        ); overload;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiBeginRequest.create(
        const role : byte;
        const flag: byte;
        const reserved1 : shortstring
    );
    begin
        inherited create();
        fType := FCGI_BEGIN_REQUEST;
        fRole := role;
        fFlags := flag;
        fReserved1 := reserved1;
        setContentData(packPayload());
    end;

    constructor TFcgiBeginRequest.create();
    begin
        create(FCGI_UNKNOWN_ROLE, 0, '');
    end;
end.
