unit NetUtil;

{$MODE OBJFPC}
{$H+}

interface

uses
   {$IFDEF WINDOWS}
   Windows,
   Winsock2
   {$ELSE}
   baseunix,
   unix
   {$ENDIF};

{$IFDEF WINDOWS}
function setNonBlocking(fd: TSocket) : longint;
function readDiscardAll(fd: TSocket) : longint;
{$ELSE}
function setNonBlocking(fd: longint) : longint;
// read all data and discard it just to empty buffer
function readDiscardAll(fd: longint) : longint;

{$ENDIF}

implementation

{$IFDEF WINDOWS}
function setNonBlocking(fd: TSocket) : longint;
const ENABLE_NON_BLOCKING = 1;
var mode: Dword;
begin
    mode := ENABLE_NON_BLOCKING;
    result := ioctlsocket(fd, longint(FIONBIO), mode);
end;

function readDiscardAll(fd: TSocket) : longint;
var
//  IOCtx: PBuff;
  Flags: DWORD;
  BytesRecv: DWORD;
  //WSABuf: TWSABUF;
begin
  //New(IOCtx);
  //FillChar(IOCtx^.Overlapped, SizeOf(TOverlapped), 0);
  //IOCtx^.Operation := ioRead;
  //IOCtx^.Connection := Conn;
  //Conn^.IOContext := IOCtx;
  //
  //WSABuf.len := SizeOf(IOCtx^.Buffer);
  //WSABuf.buf := @IOCtx^.Buffer[0];
  //Flags := 0;
  //
  //if WSARecv(Conn^.Sock, @WSABuf, 1, BytesRecv, Flags, @IOCtx^.Overlapped, nil) = SOCKET_ERROR then
  //begin
  //  if WSAGetLastError <> WSA_IO_PENDING then
  //  begin
  //    if Conn^.IOContext = IOCtx then
  //      Conn^.IOContext := nil;
  //    Dispose(IOCtx);
  //    CloseConnection(Conn);
  //  end;
  //end;
end;

{$ELSE}

function setNonBlocking(fd: longint) : longint;
var flags: longint;
begin
    flags := fpfcntl(fd, F_GETFL, 0);
    result := fpfcntl(fd, F_SETFL, flags or O_NONBLOCK);
end;

function readDiscardAll(fd: longint) : longint;
var numrd, sz: longint;
    data: array[0..255] of byte;
begin
    sz := sizeof(data);
    while true do
    begin
       numrd := fpRead(fd, data[0], sz);
       if (numrd < 0) then
       begin
          if (errno = ESysEAGAIN) or (errno = ESysEWOULDBLOCK) then
          begin
             // non blocking and no more data, exit normally
             exit(0);
          end;
          // error
          exit(errno);
       end;

       if numrd < sz then
       begin
          // all data has been read, exit normally
          exit(0);
       end;
    end;
    result := 0;
end;
{$ENDIF}

end.
