{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit LocalClamdAvImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    ssockets,
    AbstractClamdAvImpl;

type

    (*!-----------------------------------------------
     * class having capability to scan file for computer virus using
     * ClamAV daemon server over TCP socket. This is to validate uploaded file
     * This assumes that clamav daemon is run in the same machine as
     * our application, thus it has access to file content directly
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TLocalClamdAv = class(TAbstractClamdAv)
    protected
        function doSendScanRequest(
            const socket : TSocketStream;
            const filePath : string
        ) : string; override;
    end;

implementation

const

    BUFF_SIZE = 2 * 1024;

    function TLocalClamdAv.doSendScanRequest(
        const socket : TSocketStream;
        const filePath : string
    ) : string;
    var command : string;
        buff : string;
        buffRead : integer;
    begin
        result := '';
        command := 'nSCAN ' + filePath + #10;
        socket.writeBuffer(command[1], length(command));
        setLength(buff, BUFF_SIZE);
        repeat
            buffRead := socket.read(buff[1], BUFF_SIZE);
            if buffRead > 0 then
            begin
                //TODO: improve by avoiding string concatenation and copy
                result := result + copy(buff, 1, buffRead);
            end;
        until (buffRead <= 0);
    end;

end.
