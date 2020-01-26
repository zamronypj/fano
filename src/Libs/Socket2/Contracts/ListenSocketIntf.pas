{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit Socket2SvrImpl;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability setup
     * listening socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IListenSocket = interface (ISocket)
        ['{BD4BDF1B-4536-40FA-8E1D-47C94824EE23}']

        (*!-----------------------------------------------
         * return textual information regarding socket
         *-----------------------------------------------*)
        function getInfo() : string;

        (*!-----------------------------------------------
         * bind socket to an socket address
         *-----------------------------------------------*)
        procedure bind();

        (*!-----------------------------------------------
        * accept connection
        *-------------------------------------------------
        * @param listenSocket, socket handle
        * @return client socket which data can be read
        *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint;

        (*!-----------------------------------------------
         * start listen for incoming connection
         *-----------------------------------------------*)
        procedure listen();
    end;

implementation

end.
