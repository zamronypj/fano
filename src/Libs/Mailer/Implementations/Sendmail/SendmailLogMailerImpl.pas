{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SendmailLogMailerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    LoggerIntf,
    process,
    SendmailConsts,
    SendmailMailerImpl;

type

    (*!------------------------------------------------
     * class having capability to
     * send email using sendmail and log it
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSendmailLogMailer = class(TSendmailMailer)
    private
        fLogger : ILogger;
        procedure logOutput(const proc : TProcess);
    protected
        procedure executeSendmail(const proc : TProcess); override;
    public
        constructor create(
            const logger : ILogger;
            const sendmailBin : string = DEFAULT_SENDMAIL_BIN
        );
        destructor destroy(); override;
    end;

implementation

uses

    Classes,
    SysUtils,
    httpprotocol;

const

    BUFF_SIZE = 4 * 1024;

    constructor TSendmailLogMailer.create(
        const logger : ILogger;
        const sendmailBin : string = DEFAULT_SENDMAIL_BIN
    );
    begin
        inherited create(sendmailBin);
        fLogger := logger;
    end;

    destructor TSendmailLogMailer.destroy();
    begin
        fLogger := nil;
        inherited destroy();
    end;

    procedure TSendmailLogMailer.executeSendmail(const proc : TProcess);
    begin
        proc.parameters.add('-v');
        inherited executeSendmail(proc);
        logOutput(proc);
    end;

    procedure readOutput(
        const procStream : TStream;
        const str : TStream
    );
    var readCount : int64;
        buffer : pointer;
    begin
        getMem(buffer, BUFF_SIZE);
        try
            repeat
                readCount := procStream.read(buffer^, BUFF_SIZE);
                str.writeBuffer(buffer^, readCount);
            until readCount = 0;
        finally
            freeMem(buffer);
        end;
    end;

    procedure TSendmailLogMailer.logOutput(const proc : TProcess);
    var str : TStringStream;
    begin
        str := TStringStream.create('');
        try
            //readOutput(proc.output, str);
            fLogger.info(str.dataString);
        finally
            str.free();
        end;
    end;
end.
