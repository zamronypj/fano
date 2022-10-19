{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit WebAppImpl;

interface

{$MODE OBJFPC}

uses

    RunnableIntf,
    AppIntf,
    EventLoopIntf;

type

    TWebApplication = class (TInterfacedObject, IWebApplication)
    private
        fEventLoop : IEventLoop;

        procedure runEventLoop();
        procedure initialize();
        procedure shutdown();
    public
        constructor create(const eventLoop : IEventLoop);
        function run() : IRunnable;
    end;

implementation

    constructor TWebApplication.create(const eventLoop : IEventLoop);
    begin
        fEventLoop := eventLoop;
    end;

    procedure TWebApplication.runEventLoop();
    begin
        repeat
            aEv := fEventLoop.waitForEvent();
            fEventLoop.notify(aEv);
        until fEventLoop.isTerminated();
    end;

    procedure TWebApplication.initialize();
    begin
        fEventLoop.initialize();
    end;

    procedure TWebApplication.shutdown();
    begin
        fEventLoop.shutdown();
    end;

    function TWebApplication.run() : IRunnable;
    begin
        initialize();
        try
            result := runEventLoop();
        finally
            shutdown();
        end;
    end;
end.
