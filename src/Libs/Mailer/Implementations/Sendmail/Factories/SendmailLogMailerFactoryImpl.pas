{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SendmailLogMailerFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    LoggerIntf,
    FactoryImpl;

type

    (*!------------------------------------------------
     * factory class for TSendmailLogMailer
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    TSendmailLogMailerFactory = class(TFactory, IDependencyFactory)
    private
        fSendmailBin : string;
        fLogger : ILogger;
    public
        constructor create();
        function sendmailBin(const sendmailBinPath : string) : TSendmailLogMailerFactory;
        function logger(const alogger : ILogger) : TSendmailLogMailerFactory;
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    SendmailConsts,
    SendmailLogMailerImpl;

    constructor TSendmailLogMailerFactory.create();
    begin
        fSendmailBin := DEFAULT_SENDMAIL_BIN;
    end;

    function TSendmailLogMailerFactory.sendmailBin(const sendmailBinPath : string) : TSendmailLogMailerFactory;
    begin
        fSendmailBin := sendmailBinPath;
        result := self;
    end;

    function TSendmailLogMailerFactory.logger(const alogger : ILogger) : TSendmailLogMailerFactory;
    begin
        fLogger := alogger;
        result := self;
    end;

    function TSendmailLogMailerFactory.build(const container : IDependencyContainer) : IDependency;
    begin
        result := TSendmailLogMailer.create(fLogger, fSendmailBin);
    end;

end.
