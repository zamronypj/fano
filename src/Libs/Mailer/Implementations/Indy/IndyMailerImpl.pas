{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2020 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit IndyMailerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    IdSMTP,
    IndyTypes,
    AbstractMailerImpl;

type

    (*!------------------------------------------------
     * class having capability to
     * send email using Indy IdSMTP
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TIndyMailer = class(TAbstractMailer)
    private
        fSmtp : TIdSMTP;
        fConfig : TSmtpConfig;
    public
        constructor create(const cfg : TSmtpConfig);
        destructor destroy(); override;
        function send() : boolean; override;
    end;

implementation

uses

    Classes,
    SysUtils,
    IdMessage,
    IdAttachment,
    IdAttachmentMemory,
    IdExplicitTLSClientServerBase;

    constructor TIndyMailer.create(const cfg : TSmtpConfig);
    begin
        fSmtp := TIdSMTP.create();
        fConfig := cfg;
        fSmtp.host := cfg.host;
        fSmtp.port := cfg.port;
        fSmtp.username := cfg.username;
        fSmtp.password := cfg.password;
        fSmtp.ConnectTimeout := cfg.timeout;
        if cfg.useTls then
        begin
            fSmtp.useTLS := utUseExplicitTLS;
        end;
    end;

    destructor TIndyMailer.destroy();
    begin
        fSmtp.free();
        inherited destroy();
    end;

    function TIndyMailer.send() : boolean;
    var msg : TIdMessage;
        attach : TIdAttachmentMemory;
    begin
        msg := TIdMessage.create(nil);
        try
            msg.from.address := composeSender();
            msg.recipients.EmailAddresses := composeRecipient();
            msg.subject := subject;
            msg.body.text := body;

            attach := nil;
            if (attachment <> nil) and (attachment.Size >0) then
            begin
                attach := TIdAttachmentMemory.create(msg.messageParts, attachment);
            end;

            try
                fSmtp.connect();
                try
                    fSmtp.send(msg);
                finally
                    if fSmtp.connected then
                    begin
                        fSmtp.disconnect();
                    end;
                end;
            finally
                attach.free();
            end;

        finally
            msg.free();
        end;
    end;
end.
