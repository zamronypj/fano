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
    public
        constructor create(const sendmailBin : string);
        function send() : boolean; override;
    end;

implementation

uses
    Classes,
    process;

    constructor TSendmailMailer.create(const sendmailBin : string);
    begin
        fSendmailBin := sendmailBin;
    end;

    function TSendmailMailer.compose() : string;
    begin
        result := 'To: ' + fTo + LineEnding
            'Subject: ' + fSubject + LineEnding +
            'Body: ' + fMessage + LineEnding;
    end;

    function TSendmailMailer.send() : boolean;
    var proc : TProcess;
        inputStr : TStream;
    begin
        proc := TProcess.create(nil);
        try
            proc.executable := fSendmailBin;
            proc.parameters.add('-vt');
            proc.Options := proc.Options + [poUsePipes];
            proc.execute();

            //pipe email body to sendmail STDIN
            inputStr := TStringStream.create(compose());
            try
                proc.input.copyFrom(inputStr);
            finally
                inputStr.free();
            end;
            result := (proc.exitCode = 0);
        finally
            proc.free();
        end;
    end;
end.
