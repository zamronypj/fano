{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit RandomIntf;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes;

type

    (*!------------------------------------------------
     * interface for any class having capability to
     * send email
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IMailer = interface
        ['{0C1A40B2-9FD3-470A-8BBD-241D5686DEB3}']

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

        function send() : boolean;
    end;

implementation
end.
