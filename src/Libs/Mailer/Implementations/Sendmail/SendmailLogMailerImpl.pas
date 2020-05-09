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
        //TODO log output
    end;

end.
