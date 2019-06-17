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

    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Standard input binary stream (FCGI_STDIN)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdIn = class(TFcgiRecord)
    public
        constructor create(const stream : IStreamAdapter; const requestId : word);
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdIn.create(const stream : IStreamAdapter; const requestId : word);
    begin
        inherited create(FCGI_STDIN, requestId, content);
    end;

end.
