{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SockStreamImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes;

type

    (*!-----------------------------------------------
     * stream implementation that read/write socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSockStream = class(THandleStream)
    public
        function read(var buffer; count: longint): longint; override;
        function write(const buffer; count: longint): longint; override;
    end;

implementation

uses

    sockets;

    function TSockStream.read(var buffer; count: longint): longint;
    begin
        result := fpRecv(Handle, @buffer, bount, 0);
    end;

    function TSockStream.write(const buffer; count: longint): longint;
    begin
        result := fpSend(Handle, @buffer, bount, 0);
    end;

end.
