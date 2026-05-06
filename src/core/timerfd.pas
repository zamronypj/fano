unit TimerFD;

interface

uses
  BaseUnix;

type

  TClockID = (
    CLOCK_REATIME = 0,
    CLOCK_MONOTONIC = 1,
    CLOCK_BOOTTIME = 7,
    CLOCK_REALTIME_ALARM = 8,
    CLOCK_BOOTTIME_ALARM = 9
  );

   pitimerspec =^itimerspec;
   itimerspec = record
     it_interval, it_value: timespec;
  end;

function timerfd_create(ClockID: TClockID; Flags: longint): longint;cdecl; external;

function timerfd_settime(
  TimerFD: dword;
  Flags: cint;
  new_value: pitimerspec;
  old_value: pitimerspec): cint; cdecl; external;

function timerfd_gettime(
  TimerFD: dword;
  curr_value: pitimerspec): cint; cdecl; external;

implementation

end.
