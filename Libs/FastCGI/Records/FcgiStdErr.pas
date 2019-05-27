{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
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
