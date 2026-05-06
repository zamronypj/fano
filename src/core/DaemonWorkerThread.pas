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
            aCleanIdleConnInterval: integer);

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
    aCleanIdleConnInterval: integer);
begin
   inherited Create(asuspended);
   fThreadUserData := nil;
   fEventFD := aEventFd;
   fListenFD:= aListenFd;
   fExitFd := aExitFd;
   fTimerFd := aTimerFd;
   fTimeout := aTimeout;
   fCleanIdleConnInterval := aCleanIdleConnInterval;

   {$IFDEF VERBOSE}
   log('create worker thread '+ className);
   {$ENDIF}
end;

procedure TDaemonWorkerThread.fireAcceptEv(conn : PConnData);
begin
    if assigned(fOnAccepted) then
    begin
       fOnAccepted(conn^.connfd, conn^.userData);
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
