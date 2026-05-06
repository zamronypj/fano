unit ConnProcessorThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   baseunix,
   unix,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type

   { TConnProcessorThread }

   TConnProcessorThread = class(TDaemonWorkerThread)
   private
       fClosePipeOutFd: longint;
       function handleClientConn(var conn: PConnData): TOpStatus;
   protected
       procedure RunLoop(); override;
   public
       constructor Create(
           aSuspended : boolean;
           aListenFd: longint;
           aExitFd: longint;
           aTimerFd: longint;
           aClosePipeOutFd: longint;
           aTimeout: longint;
           aCleanIdleConnInterval: integer);

   end;

implementation

uses
    SyncObjs,
    logger;

{ TConnProcessorThread }

const
    DEF_DEQUEUE_TIMEOUT = 5 * 1000;

function TConnProcessorThread.handleClientConn(var conn: PConnData): TOpStatus;
var isEnded, isError: boolean;
begin
    result := default(TOpStatus);
    isEnded := false;
    isError := false;
    fireDataAvailEv(conn,
        conn^.isRead,
        conn^.isWrite,
        isEnded,
        isError);

    if isEnded or isError then
    begin
        if isError then
        begin
           logErr('conn processor failed');
        end;

        // sent connfd to close back to SelectWorkerThread
        fpWrite(fClosePipeOutFd, conn^.connfd, sizeof(longint));
        {$IFDEF VERBOSE}
        log('request closing conn ' + intToStr(conn^.connfd));
        {$ENDIF}

        exit;
    end;

    {$IFDEF VERBOSE}
    log('touch conn ' + intToStr(conn^.connfd));
    {$ENDIF}
    touchConnData(conn);
end;

procedure TConnProcessorThread.RunLoop;
var conn : PConnData;
begin
    conn := nil;
    while not Terminated do
    begin
        if dequeueConnData(DEF_DEQUEUE_TIMEOUT, conn) = wrSignaled then
        begin
            // if we get conn nil, this mostly because current thread when
            // enter lock, other thread already empty queue
            if conn <> nil then
            begin
                {$IFDEF VERBOSE}
                log('handle conn ' + intToStr(conn^.connfd));
                {$ENDIF}
                handleClientConn(conn);
            end;
        end;
    end;
end;

constructor TConnProcessorThread.Create(aSuspended: boolean;
  aListenFd: longint; aExitFd: longint; aTimerFd: longint;
  aClosePipeOutFd: longint; aTimeout: longint; aCleanIdleConnInterval: integer);
begin
    inherited Create(aSuspended, 0, aListenFd, aExitFd, aTimerFd, aTimeout, aCleanIdleConnInterval);
    fClosePipeOutFd:= aClosePipeOutFd;
end;

end.
