{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit ListenSockWorkerServerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    Classes,
    SysUtils,
    Sockets,
    SSockets,
    BoundSocketServerImpl,
    BaseWorkerServerImpl;

type

    (*!-----------------------------------------------
     * FastCGI web application worker server implementation
     * using webserver bound socket FCGI_LISTENSOCK_FILENO
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TListenSockWorkerServer = class(TBaseWorkerServer)
    public

        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------*)
        constructor create();
    end;

implementation

uses

    fastcgi;

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------*)
    constructor TListenSockWorkerServer.create();
    begin
        inherited create();
        fServer := TBoundSocketServer.create(FCGI_LISTENSOCK_FILENO, nil);
        fServer.OnConnect := @DoConnect;
    end;

end.
