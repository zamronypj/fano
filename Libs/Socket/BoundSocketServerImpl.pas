{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BoundSocketServerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    sockets,
    ssockets;

type


    (*!-----------------------------------------------
     * Socket server that use already bound socket instead of
     * bind and listen on its own
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBoundSocketServer = class(TSocketServer)
    protected
        procedure bind(); override;
    public
        procedure listen();
    end;

implementation


    procedure TBoundSocketServer.bind();
    begin
        //socket is assumed already bound and listening, so do nothing here
        //only mark status as bound
        fBound := true;
    end;

    procedure TBoundSocketServer.listen();
    begin
        //socket is assumed already bound and listening, so do nothing here
    end;
end.
