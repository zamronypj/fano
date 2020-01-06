{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit SocketClientImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    BaseUnix,
    Unix,
    SocketClientIntf;

type

    (*!-----------------------------------------------
     * Socket client implementation
     *-------------------------------------------------
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSocketClient = class abstract (TInterfacedObject, ISocketClient)
    private
        fSocket : longint;
    public
        (*!-----------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param sock, socket handle created with fpSocket()
         *-----------------------------------------------*)
        constructor create(sock : longint);

        (*!-----------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        function connect() : IStreamAdapter; virtual; abstract;
    end;

implementation

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param sock, socket handle created with fpSocket()
     *-----------------------------------------------*)
    constructor TSocketClient.create(sock : longint);
    begin
        fSocket := sock;
    end;

    (*!-----------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TSocketClient.destroy();
    begin
        fpClose(fSocket);
        inherited destroy();
    end;

end.
