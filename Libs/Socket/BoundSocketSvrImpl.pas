{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BoundSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    SocketSvrImpl;

type

    (*!-----------------------------------------------
     * bound socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBoundSocketSvr = class(TSocketSvr)
    protected
        procedure bind(); override;
        procedure shutdown(); override;
    public
        procedure run();
    end;

implementation

    procedure TBoundSocketSvr.bind();
    begin
        //socket already bound and listen
        //do nothing
    end;

    procedure TBoundSocketSvr.shutdown();
    begin
        //do nothing
    end;

    procedure TBoundSocketSvr.run();
    begin
        //skip running bind() and listen() as our socket already bound and listened
        runLoop();
    end;
end.
