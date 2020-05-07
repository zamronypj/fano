{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit AbstractMailerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    InjectableObjectImpl,
    MailerIntf;

type

    (*!------------------------------------------------
     * abstract class having capability to
     * send email
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TAbstractMailer = class(TInjectableObject, IMailer)
    private
        fTo : string;
        fFrom : string;
        fSubject : string;
        fMessage : string;
        fAttachment : TStream;
        fHeader : string;
    public
        function getTo() : string;
        procedure setTo(const aTo : string);
        property &to : string read getTo write setTo;

        function getFrom() : string;
        procedure setFrom(const aFrom : string);
        property from : string read getFrom write setFrom;

        function getSubject() : string;
        procedure setSubject(const aSubject : string);
        property subject : string read getSubject write setSubject;

        function getMessage() : string;
        procedure setMessage(const aMessage : string);
        property &message : string read getMessage write setMessage;

        function getAttachment() : TStream;
        procedure setAttachment(const aAttachment : TStream);
        property attachment : string read getAttachment write setAttachment;

        function getHeader() : string;
        procedure setHeader(const aHeader : string);
        property header : string read getHeader write setHeader;

        function send() : boolean; virtual; abstract;
    end;

implementation

    function TAbstractMailer.getTo() : string;
    begin
        result := fTo;
    end;

    procedure TAbstractMailer.setTo(const aTo : string);
    begin
        fTo := aTo;
    end;

    function TAbstractMailer.getFrom() : string;
    begin
        result := fFrom;
    end;

    procedure TAbstractMailer.setFrom(const aFrom : string);
    begin
        fFrom := aFrom;
    end;

    function TAbstractMailer.getSubject() : string;
    begin
        result := fSubject;
    end;

    procedure TAbstractMailer.setSubject(const aSubject : string);
    begin
        fSubject := aSubject;
    end;

    function TAbstractMailer.getMessage() : string;
    begin
        result := fMessage;
    end;

    procedure TAbstractMailer.setMessage(const aMessage : string);
    begin
        fMessage := aMessage;
    end;

    function TAbstractMailer.getAttachment() : TStream;
    begin
        result := fAttachment;
    end;

    procedure TAbstractMailer.setAttachment(const aAttachment : TStream);
    begin
        fAttachment := aAttachment;
    end;

    function TAbstractMailer.getHeader() : string;
    begin
        result := fHeader;
    end;

    procedure TAbstractMailer.setHeader(const aHeader : string);
    begin
        fHeader := aHeader;
    end;

end.
