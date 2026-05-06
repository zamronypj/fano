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
