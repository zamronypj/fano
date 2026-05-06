unit TimerEpollEvUtil;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,
  SysUtils,
  BaseUnix,
  Unix,
  Linux,
  ServerTypes;

function addTimerEv(aEpollFd, atimerfd: longint): TOpStatus;
function modTimerEv(aEpollFd, atimerfd: longint): TOpStatus;

implementation

function addTimerEv(aEpollFd, atimerfd: longint): TOpStatus;
var ev: epoll_event;
begin
    result := default(TOpStatus);
    ev := default(epoll_event);
    // need to use oneshot edge-triggered so that only one thread get notified
    // when need to do clean up idle connection so that it minimize chance of
    // need wait for lock to clean up
    ev.events := EPOLLIN or EPOLLET or EPOLLONESHOT;
    ev.data.fd := atimerfd;
    if (epoll_ctl(aEpollFd, EPOLL_CTL_ADD, atimerfd, @ev) < 0) then
    begin
        result.error := true;
        result.errCode := errno;
        result.errMsg := 'timer epoll_ctl() EPOLL_CTL_ADD failed. Fd:' + intToStr(atimerfd);
        exit;
    end;
end;

function modTimerEv(aEpollFd, atimerfd: longint): TOpStatus;
var ev: epoll_event;
begin
    result := default(TOpStatus);
    ev := default(epoll_event);
    // need to use oneshot edge-triggered so that only one thread get notified
    // when need to do clean up idle connection so that it minimize chance of
    // need wait for lock to clean up
    ev.events := EPOLLIN or EPOLLET or EPOLLONESHOT;
    ev.data.fd := atimerfd;
    if (epoll_ctl(aEpollFd, EPOLL_CTL_MOD, atimerfd, @ev) < 0) then
    begin
        result.error := true;
        result.errCode := errno;
        result.errMsg := 'timer epoll_ctl() EPOLL_CTL_MOD failed. Fd: ' + intToStr(atimerfd);
        exit;
    end;
end;

end.

