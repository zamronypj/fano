{-------------------------------------------------------------------------------
MIT License

Copyright (c) 2018 - Present Zamrony P. Juhara

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-------------------------------------------------------------------------------}
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
