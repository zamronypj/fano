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
    public
        constructor create(const actualSvc : IDaemonAppServiceProvider);
    end;

implementation

uses

    MhdProcessorImpl,
    MhdStdOutWriterImpl;


    constructor TMhdAppServiceProvider.create(const actualSvc : IDaemonAppServiceProvider);
    begin
        inherited create(actualSvc);
        fProtocol := TMhdProcessor.create();
        fStdOut := TMhdStdOutWriter.create();
    end;

end.
