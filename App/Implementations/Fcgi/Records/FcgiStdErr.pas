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

type

    (*!-----------------------------------------------
     * Standard error binary stream (FCGI_STDERR)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdErr = class(TFcgiRecord)
    public
        constructor create(const content : string = '');
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdErr.create(const content : string = '');
    begin
        inherited create();
        fType := FCGI_STDERR;
        setContentData(content);
    end;
end.
