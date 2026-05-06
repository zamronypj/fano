unit SigTermUtil;

interface

{$MODE OBJFPC}
{$H+}

uses

    BaseUnix,
    Unix;


function getExitFd(): longint;

implementation

uses

    NetUtil;

var

    termPipeInFd : longint;
    termPipeOutFd : longint;

(*!-----------------------------------------------
 * signal handler that will be called when
 * SIGTERM, SIGINT and SIGQUIT is received
 *-------------------------------------------------
 * @param sig, signal id i.e, SIGTERM, SIGINT or SIGQUIT
 * @param info, information about signal
 * @param ctx, contex about signal
 *-------------------------------------------------
 * Signal handler must be ordinary procedure
 *-----------------------------------------------*)
procedure doTerminate(sig : longint; info : PSigInfo; ctx : PSigContext); cdecl;
var ch : char;
begin
    //write one byte to mark termination
    ch := '.';
    fpWrite(termPipeOutFd, ch, 1);
end;

(*!-----------------------------------------------
 * install signal handler
 *-------------------------------------------------
 * @param aSig, signal id i.e, SIGTERM, SIGINT or SIGQUIT
 *-----------------------------------------------*)
procedure installTerminateSignalHandler(aSig : longint);
var oldAct, newAct : SigactionRec;
begin
    fillChar(newAct, sizeOf(SigactionRec), #0);
    fillChar(oldAct, sizeOf(Sigactionrec), #0);
    newAct.sa_handler := @doTerminate;
    if fpSigaction(aSig, @newAct, @oldAct) < 0 then
    begin
      writeln('sigaction failed');
    end;
end;

procedure makePipeNonBlocking(termPipeIn: longint; termPipeOut : longint);
begin
    //read control flag and set pipe in to be non blocking
    setNonBlocking(termPipeIn);

    //read control flag and set pipe out to be non blocking
    setNonBlocking(termPipeOut);
end;

procedure installExitFd();
begin
    //setup non blocking pipe to use for signal handler.
    //Need to be done before install handler to prevent race condition
    assignPipe(termPipeInFd, termPipeOutFd);
    makePipeNonBlocking(termPipeInFd, termPipeOutFd);

    //install signal handler after pipe setup
    installTerminateSignalHandler(SIGTERM);
    installTerminateSignalHandler(SIGINT);
    installTerminateSignalHandler(SIGQUIT);
end;

procedure uninstallExitFd();
begin
    fpClose(termPipeInFd);
    fpClose(termPipeOutFd);
end;

function getExitFd(): longint;
begin
    result := termPipeInFd;
end;

initialization

    installExitFd();

finalization

    uninstallExitFd();

end.

