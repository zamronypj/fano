{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit FcgiStdIn;

interface

{$MODE OBJFPC}
{$H+}

uses

    FcgiStreamRecord;

type

    (*!-----------------------------------------------
     * Standard input binary stream (FCGI_STDIN)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdIn = class(TFcgiStreamRecord)
    public
        constructor create(const requestId : word; const content : string = '');
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdIn.create(const requestId : word; const content : string = '');
    begin
        inherited create(FCGI_STDIN, requestId, content);
    end;

end.
