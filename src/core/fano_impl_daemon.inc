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


