{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
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
