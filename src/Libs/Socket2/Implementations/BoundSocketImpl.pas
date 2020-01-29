{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit BoundSocketImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    AbstractSocketImpl;

type

    (*!------------------------------------------------
     * class having capability setup Unix socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TBoundSocket = class (TAbstractSocket)
    protected
        function createSocket() : longint; override;
        (*!-----------------------------------------------
         * return textual information regarding socket
         *-----------------------------------------------*)
        function getInfo() : string; override;

    public
        (*!-----------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param listenSocket bound socket
         *-----------------------------------------------*)
        constructor create(const listenSocket : longint);

        (*!-----------------------------------------------
         * bind socket to an socket address
         *-----------------------------------------------*)
        procedure bind(); override;

        (*!-----------------------------------------------
        * accept connection
        *-------------------------------------------------
        * @param listenSocket, socket handle
        * @return client socket which data can be read
        *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; override;

        (*!-----------------------------------------------
         * start listen for incoming connection
         *-----------------------------------------------*)
        procedure listen(); override;
    end;

implementation

    function TBoundSocket.createSocket() : longint;
    begin
        result := fListenSocket;
    end;

    function TBoundSocket.getInfo() : string;
    begin
        result := format('Bound socket %d', [fListenSocket]);
    end;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param filename socket filename
     *-----------------------------------------------*)
    constructor TBoundSocket.create(const listenSocket : longint);
    begin
        fListenSocket := listenSocket;
        inherited create();
    end;

    (*!-----------------------------------------------
     * bind socket to socket address
     *-----------------------------------------------*)
    procedure TBoundSocket.bind();
    begin
        //intentionally does nothing as listenSocket is assumed already bound
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TBoundSocket.accept(listenSocket : longint) : longint; override;
    begin
        result := fpAccept(listenSocket, nil, nil);
    end;

    (*!-----------------------------------------------
     * start listen for incoming connection
     *-----------------------------------------------*)
    procedure TBoundSocket.listen();
    begin
        //intentionally does nothing as listenSocket is assumed already bound and listen
    end;

end.
