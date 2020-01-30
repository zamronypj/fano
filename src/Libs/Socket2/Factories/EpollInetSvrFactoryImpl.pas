{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EpollInetSvrFactoryImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    DependencyIntf,
    DependencyContainerIntf,
    RunnableWithDataNotifIntf,
    FactoryImpl;

type
    (*------------------------------------------------
     * factory class for socket server using IP
     * and Linux epoll API
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollInetSvrFactory = class(TFactory, IDependencyFactory)
    private
        fHost : string;
        fPort : word;
    public
        constructor create(const aHost : string; const aPort : word);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    SocketOptsIntf,
    Socket2SvrImpl,
    SocketOptsImpl,
    InetSocketImpl,
    EpollIoHandlerImpl;

    constructor TEpollInetSvrFactory.create(const aHost : string; const aPort : word);
    begin
        fHost := aHost;
        fPort := aPort;
    end;

    function TEpollInetSvrFactory.build(const container : IDependencyContainer) : IDependency;
    var sockOpts : ISocketOpts;
    begin
        sockOpts := TSocketOpts.create();
        result := TSocket2Svr.create(
            TInetSocket.create(fHost, fPort, sockOpts),
            TEpollIoHandler.create(sockOpts)
        );
    end;

end.
