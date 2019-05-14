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

    (*!-----------------------------------------------
     * Begin Request record (FCGI_BEGIN_REQUEST)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiBeginRequest = class(TFcgiRecord)
    private
        fRole : byte;
        fFlags : byte;
        fReserved1 : shortstring;
    public
        constructor create(
            const role : byte;
            const flag: byte;
            const reserved1 : shortstring
        );
    end;

implementation

uses

    fastcgi;

    constructor TFcgiBeginRequest.create(
        const role : byte = FCGI_UNKNOWN_ROLE;
        const flag: byte = 0;
        const reserved1 : shortstring = ''
    );
    begin
        inherited create();
        fType := FCGI_BEGIN_REQUEST;
        fRole := role;
        fFlags := flag;
        fReserved1 := reserved1;
        setContentData(packPayload());
    end;
end.
