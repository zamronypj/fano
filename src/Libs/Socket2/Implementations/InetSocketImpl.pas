{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit InetSocketImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Sockets,
    AbstractSocketImpl;

type

    (*!------------------------------------------------
     * class having capability setup IP socket
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TInetSocket = class (TAbstractSocket)
    private
        FInetAddr : TInetSockAddr;
        fHost : string;
        fPort : word;
    protected
        function createSocket() : longint; override;
    public
        (*!-----------------------------------------------
         * constructor
         *-------------------------------------------------
         * @param ahost, hostname or ip
         * @param aport, port
         *-----------------------------------------------*)
        constructor create(const ahost : string; const aport : word);

        (*!-----------------------------------------------
         * return textual information regarding socket
         *-----------------------------------------------*)
        function getInfo() : string; override;

        (*!-----------------------------------------------
         * bind socket to socket address
         *-----------------------------------------------*)
        procedure bind(); override;

        (*!-----------------------------------------------
        * accept connection
        *-------------------------------------------------
        * @param listenSocket, socket handle
        * @return client socket which data can be read
        *-----------------------------------------------*)
        function accept(listenSocket : longint) : longint; override;
    end;

implementation

    function TInetSocket.createSocket() : longint;
    begin
        result := fpSocket(AF_INET, SOCK_STREAM, 0);
    end;

    function TInetSocket.getInfo() : string;
    begin
        result := format('%s:%d', [fHost, fPort]);
    end;

    (*!-----------------------------------------------
     * constructor
     *-------------------------------------------------
     * @param host, hostname or ip
     * @param port, port
     *-----------------------------------------------*)
    constructor TInetSocket.create(const ahost : string; const aport : word);
    begin
        fHost := ahost;
        fPort := aport;
        inherited create();
    end;

    (*!-----------------------------------------------
     * bind socket to an socket address
     *-----------------------------------------------*)
    procedure TInetSocket.bind(); override;
    begin
        FInetAddr.sin_family := AF_INET;
        FInetAddr.sin_port := htons(FPort);
        FInetAddr.sin_addr.s_addr := LongWord(StrToNetAddr(FHost));
        if fpBind(getSocket(), @FInetAddr, sizeof(FInetAddr)) <> 0 then
        begin
            errCode := socketError();
            raise ESockBind.createFmt(
                rsBindFailed,
                [ getInfo(), strError(errCode), errCode ]
            );
        end;
    end;

    (*!-----------------------------------------------
     * accept connection
     *-------------------------------------------------
     * @param listenSocket, socket handle
     * @return client socket which data can be read
     *-----------------------------------------------*)
    function TInetSocket.accept(listenSocket : longint) : longint; override;
    var addrLen : TSockLen;
    begin
        addrLen := sizeof(FInetAddr);
        result := fpAccept(listenSocket, @FInetAddr, @addrLen);
    end;

end.
