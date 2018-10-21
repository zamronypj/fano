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
        startTick : longint;
        actualApp : IWebApplication;
    public
        constructor create(const app : IWebApplication);
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

uses

    sysutils;

    constructor TDebugWebApplication.create(const app : IWebApplication);
    begin
        startTick := getTickCount64();
        actualApp := app;
    end;

    destructor TDebugWebApplication.destroy();
    begin
        inherited destroy();
        actualApp := nil;
    end;

    function TDebugWebApplication.run() : IRunnable;
    var tick : longint;
    begin
        actualApp.run();
        tick := getTickCount64() - startTick;
        writeln('<!-- Exec:', tick, ' ms -->');
        result := self;
    end;

end.
