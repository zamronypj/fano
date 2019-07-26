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
    private
        procedure raiseExceptionIfAny();
    public
        function read(var buffer; count: longint): longint; override;
        function write(const buffer; count: longint): longint; override;
    end;

implementation

uses

    sockets,
    BaseUnix;

    procedure TSockStream.raiseExceptionIfAny();
    var errno : longint;
    begin
        errno := socketError();
        if (errno = ESockEWOULDBLOCK) or (errno = ESysEAGAIN) then
        begin
            //not ready for read, do nothing, we will retry
        end else
        begin
            //TODO handle other error code
        end;
    end;

    function TSockStream.read(var buffer; count: longint): longint;
    begin
        result := fpRecv(Handle, @buffer, count, 0);
        if result < 0 then
        begin
            raiseExceptionIfAny();
        end;
    end;

    function TSockStream.write(const buffer; count: longint): longint;
    begin
        result := fpSend(Handle, @buffer, count, 0);
    end;

end.
