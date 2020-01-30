{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit UnixSvrFactoryImpl;

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
     * factory class for socket server using Unix Domain
     * Socket and select()
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUnixSvrFactory = class(TFactory, IDependencyFactory)
    private
        fFilename : string;
    public
        constructor create(const aFilename : string);
        function build(const container : IDependencyContainer) : IDependency; override;
    end;

implementation

uses

    SocketOptsIntf,
    Socket2SvrImpl,
    SocketOptsImpl,
    UnixSocketImpl,
    SelectIoHandlerImpl;

    constructor TUnixSvrFactory.create(const aFilename : string);
    begin
        fFilename := aFilename;
    end;

    function TUnixSvrFactory.build(const container : IDependencyContainer) : IDependency;
    var sockOpts : ISocketOpts;
    begin
        sockOpts := TSocketOpts.create();
        result := TSocket2Svr.create(
            TUnixSocket.create(fFilename, sockOpts),
            TSelectIoHandler.create(sockOpts)
        );
    end;

end.
