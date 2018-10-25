{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 2.0)
 *}

unit DebugAppImpl;

interface

uses
    RunnableIntf,
    DependencyContainerIntf,
    AppIntf,
    DispatcherIntf,
    EnvironmentIntf,
    ErrorHandlerIntf,
    RouteCollectionIntf;

type

    (*!-----------------------------------------------
     * Decorator class that implements IWebApplication
     * and wrap other IWebApplication to calculate
     * and display execution timing
     *-----------------------------------------------*)
    TDebugWebApplication = class(TInterfacedObject, IWebApplication, IRunnable)
    private
        startTick : QWord;
        actualApp : IWebApplication;
    public
        constructor create(const app : IWebApplication);
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses

    sysutils;

    function tickCount64: QWord;
    var
      ts: TTimeSpec;
    begin
       if clock_gettime(CLOCK_MONOTONIC, @ts)=0 then
        begin
          result = int64(ts.tv_sec) * 1000 * 1000 * 1000 + start_time.tv_nsec;
          exit;
       end;
    end;

    constructor TDebugWebApplication.create(const app : IWebApplication);
    begin
        //startTick := getTickCount64();
        startTick := tickCount64;
        actualApp := app;
    end;

    destructor TDebugWebApplication.destroy();
    begin
        inherited destroy();
        actualApp := nil;
    end;

    function TDebugWebApplication.run() : IRunnable;
    var tick : Qword;
        diffMicro : double;
    begin
        actualApp.run();
        tick := tickCount64 - startTick;
        diffMicro := tick/1000;
        //tick := getTickCount64() - startTick;
        writeln('<!-- Exec:', diffMicro, ' s -->');
        result := self;
    end;

end.
