{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit EpollCloseableImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    CloseableIntf;

type

    (*!-----------------------------------------------
     * implementation that can be close socket and
     * remove from epoll monitoring
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TEpollCloseable = class(TInterfacedObject, ICloseable)
    private
        fEpollHandle : longint;
        fHandle : THandle;
        fCloseable : ICloseable;
    public
        constructor create(
            const epollHandle : longint;
            const ahandle: THandle;
            const closable : ICloseable
        );
        destructor destroy(); override;
        function close() : boolean;
    end;

implementation

uses

    sockets,
    baseunix,
    unix,
    linux;

    constructor TEpollCloseable.create(
        const epollHandle : longint;
        const ahandle: THandle;
        const closable : ICloseable
    );
    begin
        fEpollHandle := epollHandle;
        fHandle := aHandle;
        fCloseable := closable;
    end;

    destructor TEpollCloseable.destroy();
    begin
        inherited destroy();
        fCloseable := nil;
    end;

    function TEpollCloseable.close() : boolean;
    var ev : TEpoll_Event;
    begin
        //for EPOLL_CTRL_DEL, epoll_event is ignored but
        //due to bug, Linux kernel < 2.6.9 requires non-NULL,
        //here we just give them although not used.
        ev.events := EPOLLIN;
        ev.data.fd := fHandle;
        epoll_ctl(fEpollHandle, EPOLL_CTL_DEL, fHandle, @ev);

        //we need to close socket after remove from epoll,
        //@link https://idea.popcount.org/2017-03-20-epoll-is-fundamentally-broken-22/
        fCloseable.close();
        result := true;
    end;

end.
