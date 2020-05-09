{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SendmailMailerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    process,
    AbstractMailerImpl;

type

    (*!------------------------------------------------
     * class having capability to
     * send email using sendmail
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSendmailMailer = class(TAbstractMailer)
    private
        fSendmailBin : string;
        function compose() : string;
    protected
        procedure executeSendmail(const proc : TProcess); virtual;
    public
        constructor create(const sendmailBin : string);
        function send() : boolean; override;
    end;

implementation

uses

    Classes,
    SysUtils,
    httpprotocol;

    constructor TSendmailMailer.create(const sendmailBin : string);
    begin
        fSendmailBin := sendmailBin;
    end;

    function TSendmailMailer.compose() : string;
    begin
        result := 'Date: ' + formatDatetime(HTTPDateFmt, Now()) + LineEnding +
            'From: ' + getFrom() + LineEnding +
            'Subject: ' + getSubject() + LineEnding +
            'To: ' + getTo() + LineEnding +
            getHeader() + LineEnding +
            getMessage() + LineEnding;
    end;

    procedure TSendmailMailer.executeSendmail(const proc : TProcess);
    var inputStr : TStream;
    begin
        inputStr := TStringStream.create(compose());
        try
            proc.executable := fSendmailBin;
            proc.Options := proc.Options + [poUsePipes];
            proc.execute();

            //pipe email body to sendmail STDIN
            proc.input.copyFrom(inputStr, 0);
        finally
            inputStr.free();
        end;
    end;

    function TSendmailMailer.send() : boolean;
    var proc : TProcess;
    begin
        proc := TProcess.create(nil);
        try
            executeSendmail(proc);
            result := (proc.exitCode = 0);
        finally
            proc.free();
        end;
    end;
end.
