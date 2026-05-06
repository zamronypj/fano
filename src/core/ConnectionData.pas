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
unit ConnectionData;

{$MODE OBJFPC}
{$H+}

interface

uses sysutils, syncobjs;

type

    // we use linked list data to maintain
    // and remove and close idle connection
    PConnData = ^TConnData;
    TConnData = record
       connfd: longint;

       // keep track connfd last io activity
       lastActivity: int64;

       // user-defined data
       userData: pointer;

       // status indicating if connfd is readable without blocking
       isRead: boolean;

       // status indicating if connfd is readable without blocking
       isWrite: boolean;

       prev: PConnData;
       next: PConnData;
    end;

    TConnCallback = procedure(connfd: longint; var userData: pointer; callbackData: pointer);
    TTraverseConnCallback = procedure(conn: PConnData; callbackData: pointer);

// this is to provide a way to resize max connection lookup
procedure setMaxConn(amaxConn: integer);
function getMaxConn() : integer;
procedure initConnData();
procedure destroyConnData();

function addFdToConnData(connfd: longint; callbackData:pointer; callback: TConnCallback): PConnData;

// remove conn data from global connection linked list without
// deallocate its resources
function pluckConnData(connfd: longint): PConnData;

procedure removeFdFromConnData(connfd: longint; callbackData:pointer;  callback: TConnCallback);
procedure removeFromConnData(conn: PConnData; callbackData:pointer; callback: TConnCallback);
function touchConnData(conn: PConnData): PConnData;
procedure forEachConnData(callbackData: pointer; callback: TConnCallback);
procedure traverseConnData(callbackData: pointer; callback: TTraverseConnCallback);
procedure removeTimeoutConnData(atimeout:integer; callbackData: pointer; callback: TConnCallback);
procedure clearConnData(callbackData: pointer; callback: TConnCallback);

function getConnMaxFd(): longint;

procedure enqueueConnData(conn: PConnData);
function dequeueConnData(waitTimeout: cardinal; var conn : PConnData): TWaitResult;

implementation

uses DateUtils, Contnrs;

const

    DEF_MAX_CONN = 1024;

type

    TArrConnData = array of PConnData;

var

    headConn, tailConn : PConnData;
    connLookup: TArrConnData;
    pluckedConnLookup: TArrConnData;
    globalLock: TCriticalSection;
    maxConn: integer;

    connQueue: TQueue;
    queueAvail: TEvent;
    queueLock: TCriticalSection;

procedure setMaxConn(amaxConn: integer);
begin
   maxConn := amaxConn;
end;

function getMaxConn(): integer;
begin
   result := maxConn;
end;

procedure forEachConnData(callbackData: pointer; callback: TConnCallback);
var conn, next : PConnData;
begin
   globalLock.acquire();
   try
       conn := headConn;
       while conn <> nil do
       begin
           next := conn^.next;
           callback(conn^.connfd, conn^.userData, callbackData);
           conn := next;
       end;
   finally
       globalLock.release();
   end;
end;

// similar to forEachConnData except it returns PConnData
procedure traverseConnData(callbackData: pointer; callback: TTraverseConnCallback);
var conn, next : PConnData;
begin
   globalLock.acquire();
   try
       conn := headConn;
       while conn <> nil do
       begin
           next := conn^.next;
           callback(conn, callbackData);
           conn := next;
       end;
   finally
       globalLock.release();
   end;
end;

procedure _getMaxFd(connfd: longint; var userData:pointer; callbackData: pointer);
var pmaxFd: PLongint;
begin
    pmaxFd := PLongint(callbackData);
    if connfd > pmaxFd^ then
    begin
        pmaxFd^ := connfd;
    end;
end;

function getConnMaxFd(): longint;
var maxFd: longint;
begin
    maxFd := 0;
    forEachConnData(@maxFd, @_getMaxFd);
    result := maxFd;
end;

procedure initConnData();
begin
   headConn := nil;
   tailConn := nil;
   setLength(connLookup, maxConn);
   setLength(pluckedConnLookup, maxConn);
end;


procedure destroyConnData();
begin
   headConn := nil;
   tailConn := nil;
   setLength(connLookup, 0);
   setLength(pluckedConnLookup, 0);
end;

function _moveToTail(conn: PConnData) : PConnData;
begin
    conn^.prev := tailConn;
    conn^.next := nil;

    // add to linked List (Tail)
    if tailConn <> nil then
    begin
        tailConn^.next := conn;
    end;
    tailConn := conn;

    if headConn = nil then
    begin
        // if we get here, this is first conn
        headConn := conn;
    end;

    result := conn;
end;

function addFdToConnData(connfd: longint; callbackData:pointer; callback: TConnCallback): PConnData;
var conn : PConnData;
begin
    if connfd >= length(connLookup) then
    begin
        // will not fit into lookup so reject
        exit(nil);
    end;

    new(conn);
    conn^.connfd := connfd;
    conn^.lastActivity := DateTimeToUnix(now);

    // watch conn for read avail first
    conn^.isRead := true;
    conn^.isWrite := false;
    conn^.userData := nil;

    if assigned(callback) then
    begin
        callback(connfd, conn^.userData, callbackData);
    end;

    globalLock.acquire();
    try
        conn := _moveToTail(conn);

        // add to lookup array
        connLookup[connfd] := conn;
        pluckedConnLookup[connfd] := nil;
    finally
        globalLock.release();
    end;

    result := conn;
end;

function _pluckConnData(conn: PConnData): PConnData;
begin
    result := conn;

    if conn = nil then
    begin
        exit;
    end;

    // 1. Remove from Linked List
    if conn^.prev <> nil then
    begin
        conn^.prev^.next := conn^.next;
    end;

    if conn^.next <> nil then
    begin
        conn^.next^.prev := conn^.prev;
    end;

    if conn = headConn then
    begin
        headConn := conn^.next;
    end;

    if conn = tailConn then
    begin
        tailConn := conn^.prev;
    end;

    connLookup[conn^.connfd] := nil;
    pluckedConnLookup[conn^.connfd] := conn;
end;

function pluckConnData(connfd: longint): PConnData;
var conn: PConnData;
begin
   globalLock.acquire();
   try
       conn := pluckedConnLookup[connfd];
       if conn = nil then
       begin
           conn := connLookup[connfd];
           conn := _pluckConnData(conn);
       end;
       result := conn;
   finally
       globalLock.release();
   end;
end;

procedure removeFromConnData(conn: PConnData; callbackData:pointer; callback: TConnCallback);
begin
   globalLock.acquire();
   try
       conn := _pluckConnData(conn);
       if conn <> nil then
       begin
           if assigned(callback) then
           begin
               callback(conn^.connfd, conn^.userData, callbackData);
           end;
           connLookup[conn^.connfd] := nil;
           pluckedConnLookup[conn^.connfd] := nil;
           dispose(conn);
       end;
   finally
       globalLock.release();
   end;
end;

procedure removeFdFromConnData(connfd: longint; callbackData: pointer; callback: TConnCallback);
var conn: PConnData;
begin
   globalLock.acquire();
   try
       conn := pluckedConnLookup[connfd];
       if conn = nil then
       begin
           conn := connLookup[connfd];
           conn := _pluckConnData(conn);
       end;

       if conn <> nil then
       begin
           if assigned(callback) then
           begin
              callback(conn^.connfd, conn^.userData, callbackData);
           end;
           connLookup[conn^.connfd] := nil;
           pluckedConnLookup[conn^.connfd] := nil;
           dispose(conn);
       end;
   finally
       globalLock.release();
   end;
end;


// update connection last activity and move it to tail
function touchConnData(conn: PConnData) : PConnData;
begin
    globalLock.acquire();
    try
       if conn = nil then
       begin
          // todo: log invalid conn
          exit(conn);
       end;

       conn^.lastActivity := DateTimeToUnix(now);

       if conn = tailConn then
       begin
           // already at the end
           exit(conn);
       end;

       // Detach from current position
       if conn^.prev <> nil then
       begin
           conn^.prev^.next := conn^.next;
       end;

       if conn^.next <> nil then
       begin
           conn^.next^.prev := conn^.prev;
       end;

       if conn = headConn then
       begin
           headConn := conn^.next;
       end;

       result := _moveToTail(conn);

       // re-add to lookup array
       connLookup[conn^.connfd] := conn;
       pluckedConnLookup[conn^.connfd] := nil;
   finally
       globalLock.release();
   end;
end;

procedure removeTimeoutConnData(atimeout: integer; callbackData: pointer; callback: TConnCallback);
var nowTimestamp: int64;
    conn, connToDel : PConnData;
    connfd : longint;
    userData: pointer;
begin
   globalLock.acquire();
   try
       nowTimestamp := DateTimeToUnix(now);
       conn := headConn;
       while conn <> nil do
       begin
           if (nowTimestamp - conn^.lastActivity) > atimeout then
           begin
               connToDel := conn;
               // advance to next before we modify connToDel
               conn := conn^.next;

               connToDel := _pluckConnData(connToDel);

               connfd := connToDel^.connfd;
               userData := connToDel^.userData;

               connLookup[connfd] := nil;
               pluckedConnLookup[connfd] := nil;
               dispose(connToDel);

               // let caller deal with how to do with
               // conn FD dan wrapped user data
               callback(connfd, userData, callbackData);
           end else
           begin
               // linked list already sorted by recently active
               // so if conn not timeout then next conn wont be either
               // so exit early
               break;
           end;
       end;

   finally
       globalLock.release();
   end;
end;

procedure clearConnData(callbackData: pointer; callback: TConnCallback);
var conn, connToDel : PConnData;
    connfd: longint;
    userData: pointer;
begin
   globalLock.acquire();
   try
       conn := headConn;
       while conn <> nil do
       begin
           connToDel := conn;
           // advance to next before we modify connToDel
           conn := conn^.next;

           connToDel := _pluckConnData(connToDel);

           connfd := connToDel^.connfd;
           userData := connToDel^.userData;
           connLookup[connfd] := nil;
           pluckedConnLookup[connfd] := nil;

           dispose(connToDel);

           // let caller deal with how to do with
           // conn FD dan wrapped user data
           callback(connfd, userData, callbackData);
       end;

   finally
       globalLock.release();
   end;
end;

procedure enqueueConnData(conn: PConnData);
begin
    queueLock.Acquire;
    try
        connQueue.Push(conn);
    finally
        queueLock.Release;
    end;

    // set outside lock so that by the time event set, at least one thread
    // calling dequeue would not be blocked
    queueAvail.SetEvent;
end;

function dequeueConnData(waitTimeout: cardinal; var conn : PConnData): TWaitResult;
begin
    conn := nil;
    result := queueAvail.waitFor(waitTimeout);
    if result = wrSignaled then
    begin
        queueLock.Acquire;
        try
            if connQueue.count > 0 then
            begin
                conn := connQueue.Pop();
                if connQueue.count = 0 then
                begin
                    queueAvail.ResetEvent;
                end;
            end;
        finally
            queueLock.Release;
        end;
    end;
end;

initialization

   globalLock := TCriticalSection.create();
   queueLock := TCriticalSection.create();
   queueAvail := TEvent.Create(nil, true, false, 'connqueue');
   connQueue := TQueue.Create;
   maxConn := DEF_MAX_CONN;
   initConnData();

finalization

   destroyConnData();
   maxConn := 0;
   connQueue.Free;
   queueAvail.Free;
   queueLock.Free;
   globalLock.Free();

end.
