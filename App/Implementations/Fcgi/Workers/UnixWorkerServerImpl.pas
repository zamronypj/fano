{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit UnixWorkerServerImpl;

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
     * using Unix socket file
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TUnixWorkerServer = class(TBaseWorkerServer)
    public
        constructor create(const socketFilename: string);
    end;

implementation

    constructor TUnixWorkerServer.create(const socketFilename: string);
    begin
        inherited create();
        fServer := TUnixServer.create(socketFilename);
        fServer.OnConnect := @DoConnect;
    end;

end.
