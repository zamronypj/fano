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
        constructor create(
            const actualSvc : IDaemonAppServiceProvider;
            const host : string;
            const port : word
        );
        destructor destroy(); override;
        function getServer() : IRunnableWithDataNotif; override;
    end;

implementation

uses

    MhdProcessorImpl,
    MhdStdOutWriterImpl;

    constructor TMhdAppServiceProvider.create(
        const actualSvc : IDaemonAppServiceProvider;
        const host : string;
        const port : word
    );
    begin
        inherited create(actualSvc);
        fProtocol := TMhdProcessor.create(host, port);
        //TMhdProcessor also act as server
        fServer := fProtocol as IRunnableWithDataNotif;
        fStdOut := TMhdStdOutWriter.create();
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

end.
