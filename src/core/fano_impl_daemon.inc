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

uses
   NetUtil,
   ServerTypes,
   Logger,
   DaemonWorkerThread,
   NumCPULib,

   {$IF DEFINED(LINUX)}
   SigTermUtil,
   TimerFD,
   TimerEpollEvUtil,
   EpollWorkerThread,
   {$ELSEIF DEFINED(BSD)}
   SigTermUtil,
   KqueueWorkerThread,
   {$ELSEIF DEFINED(WINDOWS)}
   IocpWorkerThread,
   {$ELSE}
   SigTermUtil,
   TimerFD,
   SelectWorkerThread,
   ConnProcessorThread,
   {$ENDIF}

   {$IFDEF HTTP2}
   Http2Processor
   {$ELSE}
   HttpProcessor
   {$ENDIF};

const

    DEFAULT_PORT = 2607;
    DEFAULT_THREAD_POOL_SIZE = 4;
    DEFAULT_TIMEOUT_10S = 10 * 1000;
    DEFAULT_MAX_CONN_1024 = 1024;
    DEFAULT_TIMER_INTERVAL_1MIN = 60;

var
    mainCfg: TFanoConfig;
    workerThreads: TArrThread;

function fanoConfig(): TFanoConfig; overload;
begin
   result := mainCfg;
end;

function fanoConfig(const newCfg: TFanoConfig): TFanoConfig; overload;
begin
   mainCfg := newCfg;
   setLength(workerThreads, mainCfg.ThreadPoolSize);
   result := mainCfg;
end;


function fanoCreate(): TFanoConfig;
begin
   mainCfg.ThreadPoolSize := TNumCpuLib.GetLogicalCPUCount();
   if mainCfg.ThreadPoolSize < DEFAULT_THREAD_POOL_SIZE then
   begin
       mainCfg.ThreadPoolSize := DEFAULT_THREAD_POOL_SIZE;
   end;

   mainCfg.Port := DEFAULT_PORT;
   mainCfg.Timeout := DEFAULT_TIMEOUT_10S;
   mainCfg.MaxConn := DEFAULT_MAX_CONN_1024;
   mainCfg.CleanIdleConnInterval := DEFAULT_TIMER_INTERVAL_1MIN;
   setLength(workerThreads, mainCfg.ThreadPoolSize);
   result := fanoConfig();
end;

const
    ERR_SOCK = -1;
    ERR_BIND = -2;
    ERR_LISTEN = -3;
    ERR_EV_ADD = -4;


procedure runThreads(aWorkerThreads:TArrThread);
var i: integer;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    for i:= 0 to poolSize - 1 do
    begin
        aWorkerThreads[i].start();
    end;
end;

procedure freeThreads(aWorkerThreads:TArrThread);
var i: integer;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    for i:= 0 to poolSize - 1 do
    begin
        aWorkerThreads[i].free();
    end;
end;

procedure waitThreads(aWorkerThreads:TArrThread);
var i: integer;
    poolSize: integer;
begin
    poolSize := length(aWorkerThreads);
    for i:= 0 to poolSize - 1 do
    begin
        aWorkerThreads[i].waitFor();
    end;
end;

{$IF DEFINED(LINUX)}
   {$I fano_run_epoll.inc}
{$ELSEIF DEFINED(BSD)}
   {$I fano_run_kqueue.inc}
{$ELSEIF DEFINED(WINDOWS)}
   {$I fano_run_iocp.inc}
{$ELSE}
   {$I fano_run_select.inc}
{$ENDIF}

function fanoFree(): longint;
begin
    mainCfg := default(TFanoConfig);
    SetLength(workerThreads, 0);
    result := 0;
end;
