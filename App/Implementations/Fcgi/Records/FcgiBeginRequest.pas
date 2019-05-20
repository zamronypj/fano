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
            const requestId : word;
            const role : byte;
            const flag: byte;
            const reserved1 : shortstring
        );

        (*!------------------------------------------------
        * write record data to stream
        *-----------------------------------------------
        * @param stream, stream instance where to write
        * @return number of bytes actually written
        *-----------------------------------------------*)
        function write(const stream : IStreamAdapter) : integer; override;
    end;

implementation

uses

    fastcgi;

    constructor TFcgiBeginRequest.create(
        const requestId : word;
        const role : byte = FCGI_UNKNOWN_ROLE;
        const flag: byte = 0;
        const reserved1 : shortstring = ''
    );
    begin
        inherited create(FCGI_BEGIN_REQUEST, requestId);
        fRole := role;
        fFlags := flag;
        fReserved1 := reserved1;
        setContentData(packPayload());
    end;

    (*!------------------------------------------------
    * write record data to stream
    *-----------------------------------------------
    * @param stream, stream instance where to write
    * @return number of bytes actually written
    *-----------------------------------------------*)
    function TFcgiBeginRequest.write(const stream : IStreamAdapter) : integer;
    begin

    end;
end.
