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

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param host, hostname/IP address where server listen
         * @param port, TCP port where server listen
         *-----------------------------------------------*)
        constructor create(const host: string; const port: word);
    end;

implementation

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param host, hostname/IP address where server listen
     * @param port, TCP port where server listen
     *-----------------------------------------------*)
    constructor TTcpWorkerServer.create(const host: string; const port: word);
    begin
        inherited create();
        fServer := TInetServer.create(host, port);
        fServer.OnConnect := @DoConnect;
    end;

end.
