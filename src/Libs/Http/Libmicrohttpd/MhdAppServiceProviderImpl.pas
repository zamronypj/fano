{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit MhdAppServiceProviderImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RunnableWithDataNotifIntf,
    DaemonAppServiceProviderIntf,
    ProtocolAppServiceProviderImpl;

type

    {*------------------------------------------------
     * class having capability to
     * register one or more service factories that use
     * libmicrohttpd
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------}
    TMhdAppServiceProvider = class (TProtocolAppServiceProvider)
    private
        fServer : IRunnableWithDataNotif;
    public
        constructor create(const actualSvc : IDaemonAppServiceProvider);
        destructor destroy(); override;
        function getServer() : IRunnableWithDataNotif; override;
        function getStdIn() : IStdIn; override;
    end;

implementation

uses

    MhdProcessorImpl,
    MhdStdOutWriterImpl;

    constructor TMhdAppServiceProvider.create(const actualSvc : IDaemonAppServiceProvider);
    begin
        inherited create(actualSvc);
        fProtocol := TMhdProcessor.create();
        //TMhdProcessor also act as server
        fServer := fProtocol as IRunnableWithDataNotif;
        fStdOut := TMhdStdOutWriter.create();
        fStdIn : TMhdStdInReader.create();
    end;

    destructor TMhdAppServiceProvider.destroy();
    begin
        fServer := nil;
        inherited destroy();
    end;

    function TMhdAppServiceProvider.getServer() : IRunnableWithDataNotif;
    begin
        result := fServer;
    end;

    function TMhdAppServiceProvider.getStdIn() : IStdIn;
    begin

    end;

end.
