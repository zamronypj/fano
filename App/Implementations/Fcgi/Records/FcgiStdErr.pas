{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiStdErr;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord;

type

    (*!-----------------------------------------------
     * Standard error binary stream (FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdErr = class(TFcgiStreamRecord)
    public
        constructor create(
            const requestId : word;
            const content : string = ''
        );
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdErr.create(const requestId : word; const content : string = '');
    begin
        inherited create(FCGI_STDERR, requestId, content);
    end;
end.
