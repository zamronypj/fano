{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2021 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SynapseMailerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    synautil,
    smtpsend,
    ssl_openssl,
    ssl_openssl_lib,
    AbstractMailerImpl,
    MailerConfigTypes;

type

    (*!------------------------------------------------
     * class having capability to
     * send email using Synopse SMTPSend library
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSynapseMailer = class(TAbstractMailer)
    private
        fMailerConfig : TMailerConfig;

        function sendRaw(
            const cfg : TMailerConfig;
            const mailFrom :string;
            const mailTo: string;
            const mailData : TStrings
        ): boolean;
    public
        constructor create(const cfg : TMailerConfig);

        function send() : boolean; override;
    end;

implementation

uses

    SysUtils;

    constructor TSynapseMailer.create(const cfg : TMailerConfig);
    begin
        fMailerConfig := cfg;
    end;

    function TSynapseMailer.sendRaw(
        const cfg : TMailerConfig;
        const mailFrom :string;
        const mailTo: string;
        const mailData : TStrings
    ): boolean;
    var
        SMTP: TSMTPSend;
        multipleEmailAddr : string;
        emailAddr : string;
    begin
        result := false;
        SMTP := TSMTPSend.create();
        try
            SMTP.AutoTLS := cfg.useTLS;
            SMTP.useSSL := cfg.useSSL;
            SMTP.TargetHost := cfg.host;
            SMTP.TargetPort := IntToStr(cfg.port);
            SMTP.Username := cfg.username;
            SMTP.Password := cfg.password;

            if SMTP.Login() then
            begin
                if SMTP.MailFrom(GetEmailAddr(mailFrom), Length(mailData.Text)) then
                begin
                    //assume mailTo contains multiple mail addresses separated by comma
                    multipleEmailAddr := mailTo;
                    repeat
                        //pick single address and remove from multipleEmailAddr
                        emailAddr := GetEmailAddr(Trim(FetchEx(multipleEmailAddr, ',', '"')));
                        if emailAddr <> '' then
                        begin
                            result := SMTP.MailTo(emailAddr);
                        end;

                        if not result then
                        begin
                            break;
                        end;
                    until multipleEmailAddr = '';

                    if result then
                    begin
                        result := SMTP.MailData(mailData);
                    end;
                end;
                SMTP.Logout();
            end;
        finally
            SMTP.free();
        end;
    end;

    function TSynapseMailer.send() : boolean;
    var mailData : TStrings;
        mailFrom : string;
        mailTo : string;
    begin
        mailData := TStringList.create();
        try
            mailFrom := composeSender();
            mailTo := composeRecipient();
            mailData.add('From: ' + mailFrom);
            mailData.add('To: ' + mailTo);
            mailData.add('Date: ' + Rfc822DateTime(now));
            mailData.add('Subject: ' + subject);
            mailData.add('');
            mailData.text := mailData.text + body;
            result := sendRaw(fMailerConfig, mailFrom, mailTo, mailData);
        finally
            headers.free();
        end;
    end;
end.
