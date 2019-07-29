{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EpollBoundSocketSvrImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    RunnableIntf,
    Sockets,
    EpollSocketSvrImpl;

type

    (*!-----------------------------------------------
     * bound socket server implementation which support graceful
     * shutdown when receive SIGTERM/SIGINT signal and also
     * allow for keeping client connection open if required
     * This class using Linux epoll API to monitor file descriptors
     *---------------------------------------------------
     * TODO: refactor as this mostly same as TBoundSocketSvr only different
     * ancestor
     *---------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollBoundSocketSvr = class(TEpollSocketSvr)
    protected
        procedure bind(); override;
        procedure shutdown(); override;

        (*!-----------------------------------------------
         * begin listen socket
         *-----------------------------------------------*)
        procedure listen(); override;

        (*!-----------------------------------------------
         * accept connection
         *-------------------------------------------------
         * @param listenSocket, socket handle created with fpSocket()
         * @return client socket which data can be read
         *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; override;
    public
        function run() : IRunnable; override;
    end;

implementation

    procedure TEpollBoundSocketSvr.bind();
    begin
        //socket already bound and listen
        //do nothing
    end;

    procedure TEpollBoundSocketSvr.listen();
    begin
        //socket already bound and listen
        //do nothing
    end;

    procedure TEpollBoundSocketSvr.shutdown();
    begin
        //do nothing
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle created with fpSocket()
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TEpollBoundSocketSvr.accept(listenSocket : longint) : longint;
    begin
        result := fpAccept(listenSocket, nil, nil);
    end;

    function TEpollBoundSocketSvr.run() : IRunnable;
    begin
        //skip running bind() and listen() as our socket already bound and listened
        handleConnection();
        result := self;
    end;
end.
