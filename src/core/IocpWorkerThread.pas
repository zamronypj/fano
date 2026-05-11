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
unit IocpWorkerThread;

{$MODE OBJFPC}
{$H+}

interface

uses
   classes,
   sysutils,
   sockets,
   windows,
   Winsock2,
   ServerTypes,
   ConnectionData,
   DaemonWorkerThread;

type


   { TIocpWorkerThread }

   TIocpWorkerThread = class(TDaemonWorkerThread)
   private
        function handleClientConn(var conn: PConnData): TOpStatus;
   protected
        procedure RunLoop(); override;
   end;

implementation

uses
   DateUtils,
   SyncObjs,
   IocpTerm,
   NetUtil,
   Logger;

function TIocpWorkerThread.handleClientConn(var conn: PConnData): TOpStatus;
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

        // TODO: notify IocpAcceptThread to close conn^.connfd

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

procedure _removeCallback(connfd: TSocket; var userData: pointer; callbackData: pointer);
var canClose: boolean;
begin
    canClose := true;
    TIocpWorkerThread(callbackData).OnBeforeClose(connfd, userData, canClose);
end;

procedure TIocpWorkerThread.RunLoop();
var Overlapped: POverlapped;
    lpNumberOfBytesTransferred, lpCompletionKey : NativeUInt;
    conn: PConnData;
    hIOCP: THandle;
begin
    hIOCP := fEventFd;
    while true do
    begin
        if GetQueuedCompletionStatus(hIOCP, lpNumberOfBytesTransferred, lpCompletionKey, Overlapped, INFINITE) then
        begin
            if (lpCompletionKey = SHUTDOWN_KEY) and (overlapped = nil) then
            begin
                // IocpAcceptThread wants us to gracefully terminate
                break;
            end;

            if overlapped = nil then
            begin
                continue;
            end;

            conn := PConnData(overlapped);
            handleClientConn(conn);
        end else
        begin
            // failed
            if overlapped <> nil then
            begin
                // TODO: is it safe to do it here and not in IocpAcceptThread?
                // maybe should PostQueuedCompletionStatus to IocpAcceptThread
                // PostQueuedCompletionStatus(hIOCP, 0, CLOSE_CONN_KEY, overlapped);
                conn := PConnData(overlapped);
                removeFromConnData(conn, self, @_removeCallback);
            end;
        end;
    end;
end;

end.

