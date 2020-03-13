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
        procedure doSendScanRequest(
            const socket : TSocketStream;
            const filePath : string
        ); override;
    end;

implementation

    procedure TLocalClamdAv.doSendScanRequest(
        const socket : TSocketStream;
        const filePath : string
    );
    var command : string;
    begin
        command := 'nSCAN ' + filePath + #10;
        socket.writeBuffer(command[1], length(command));
    end;

end.
