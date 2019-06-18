{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit TcpWorkerServerImpl;

interface

{$MODE OBJFPC}
{$H+}


uses
    Classes,
    SysUtils,
    Sockets,
    SSockets,
    BaseWorkerServerImpl;

type

    (*!-----------------------------------------------
     * FastCGI web application worker server implementation
     * using TCP/IP
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TTcpWorkerServer = class(TBaseWorkerServer)
    public
        constructor create(const hostname: string; const port: word);
    end;

implementation

    constructor TTcpWorkerServer.create(const hostname: string; const port: word);
    begin
        inherited create();
        fServer := TInetServer.create(hostName, port);
        fServer.OnConnect := @DoConnect;
    end;

end.
