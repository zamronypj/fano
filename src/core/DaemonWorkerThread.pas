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
unit DaemonWorkerThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   ServerTypes,
   ConnectionData;

type


   { TDaemonWorkerThread }

   TDaemonWorkerThread = class(TThread)
   protected
        fEventFD: longint;
        fListenFD: longint;
        fExitFd: longint;
        fTimerFd: longint;
        fTimeout: longint;
        fCleanIdleConnInterval: integer;
        fMaxRequestSize: integer;
        fMaxBodySize: integer;

        // per thread user data assosiate with this thread
        // which can be used to stored per thread global data
        // such as DB connection or anything
        fThreadUserData : pointer;

        fOnBeforeRunLoop: TOnBeforeRunLoop;
        fOnAfterRunLoop: TOnAfterRunLoop;

        fOnAccepted: TOnAccepted;
        fOnDataAvail: TOnDataAvail;
        fOnBeforeClose: TOnBeforeClose;

        procedure runLoop(); virtual; abstract;
        procedure Execute(); override;
        procedure fireBeforeRunLoopEv(); virtual;
        procedure fireAfterRunLoopEv(); virtual;
        procedure fireAcceptEv(conn : PConnData); virtual;
        procedure fireDataAvailEv(conn : PConnData;
            var isRead, isWrite, isEnded, isError: boolean); virtual;
        function fireBeforeCloseEv(connfd : longint; var userData : pointer): boolean;
   public
        constructor Create(
            aSuspended : boolean;
            aEventFd:longint;
            aListenFd: longint;
            aExitFd: longint;
            aTimerFd: longint;
            aTimeout: longint;
            aCleanIdleConnInterval,
            aMaxRequestSize,
            aMaxBodySize: integer);

        // all events triggered inside thread so
        // caller must ensure that is thread safe
        property OnBeforeRunLoop: TOnBeforeRunLoop read fOnBeforeRunLoop write fOnBeforeRunLoop;
        property OnAfterRunLoop: TOnAfterRunLoop read fOnAfterRunLoop write fOnAfterRunLoop;
        property OnAccepted: TOnAccepted read fOnAccepted write fOnAccepted;
        property OnDataAvail: TOnDataAvail read fOnDataAvail write fOnDataAvail;
        property OnBeforeClose: TOnBeforeClose read fOnBeforeClose write fOnBeforeClose;

        property EventFd: longint read fEventFD;
        property threadUserData: pointer read fThreadUserData;
   end;

   TDaemonWorkerThreadClass = class of TDaemonWorkerThread;

implementation

uses
   Logger;


constructor TDaemonWorkerThread.Create(
    aSuspended : boolean;
    aEventFd:longint;
    aListenFd: longint;
    aExitFd: longint;
    aTimerFd: longint;
    aTimeout: longint;
    aCleanIdleConnInterval,
    aMaxRequestSize,
    aMaxBodySize: integer);
begin
   inherited Create(asuspended);
   fThreadUserData := nil;
   fEventFD := aEventFd;
   fListenFD:= aListenFd;
   fExitFd := aExitFd;
   fTimerFd := aTimerFd;
   fTimeout := aTimeout;
   fCleanIdleConnInterval := aCleanIdleConnInterval;
   fMaxRequestSize := aMaxRequestSize;
   fMaxBodySize := aMaxBodySize;

   {$IFDEF VERBOSE}
   log('create worker thread '+ className);
   {$ENDIF}
end;

procedure TDaemonWorkerThread.fireAcceptEv(conn : PConnData);
begin
    if assigned(fOnAccepted) then
    begin
       fOnAccepted(conn^.connfd, fMaxRequestSize, fMaxBodySize, conn^.userData);
    end;
end;

procedure TDaemonWorkerThread.fireDataAvailEv(conn: PConnData;
    var isRead, isWrite, isEnded, isError: boolean);
begin
    if assigned(fOnDataAvail) then
    begin
       fOnDataAvail(conn^.connfd, conn^.userData,
           isRead, isWrite, isEnded, isError);
    end;
end;

function TDaemonWorkerThread.fireBeforeCloseEv(connfd : longint; var userData : pointer): boolean;
var canClose: boolean;
begin
    canClose := true;
    if assigned(fOnBeforeClose) then
    begin
       fOnBeforeClose(connfd, userData, canClose);
    end;
    result := canClose;
end;


procedure TDaemonWorkerThread.fireBeforeRunLoopEv();
begin
    if assigned(fOnBeforeRunLoop) then
    begin
        // allow to allocate and associate fThreadUserData with this thread
        fOnBeforeRunLoop(self, fThreadUserData);
    end;
end;

procedure TDaemonWorkerThread.fireAfterRunLoopEv();
begin
    if assigned(fOnAfterRunLoop) then
    begin
        // allow to allocate and associate fThreadUserData with this thread
        fOnAfterRunLoop(self, fThreadUserData);
    end;
end;


procedure TDaemonWorkerThread.Execute();
begin
    {$IFDEF VERBOSE}
    log('execute worker thread '+ ClassName);
    {$ENDIF}
    fireBeforeRunLoopEv();
    try
        runLoop();
    finally
        fireAfterRunLoopEv();
    end;
end;

end.
