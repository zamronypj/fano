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
           aCleanIdleConnInterval,
           aMaxRequestSize,
           aMaxBodySize: integer);

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
  aClosePipeOutFd: longint; aTimeout: longint;
  aCleanIdleConnInterval,
  aMaxRequestSize,
  aMaxBodySize: integer);
begin
    inherited Create(aSuspended, 0, aListenFd, aExitFd, aTimerFd, aTimeout,
        aCleanIdleConnInterval, aMaxRequestSize, aMaxBodySize);
    fClosePipeOutFd:= aClosePipeOutFd;
end;

end.
