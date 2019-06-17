{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit FcgiStdOut;

interface

{$MODE OBJFPC}
{$H+}

uses

    StreamAdapterIntf,
    FcgiRecord;

type

    (*!-----------------------------------------------
     * Standard output binary stream (FCGI_STDOUT)
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TFcgiStdOut = class(TFcgiRecord)
    public
        constructor create(const stream : IStreamAdapter; const requestId : word);
        constructor create(const requestId : word; const str : string);
    end;

implementation

uses

    fastcgi;

    constructor TFcgiStdOut.create(const stream : IStreamAdapter; const requestId : word);
    begin
        inherited create(stream, FCGI_VERSION_1, FCGI_STDOUT, requestId);
    end;

    constructor TFcgiStdOut.create(const requestId : word; const str : string);
    begin
        create(TStreamAdapter.create(TStringStream.create(str)), requestId);
    end;
end.
