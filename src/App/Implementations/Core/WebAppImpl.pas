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

    constructor create(const eventLoop : IEventLoop);
    begin
        fEventLoop := eventLoop;
    end;

    procedure TFanoApplication.runEventLoop();
    begin
        repeat
            aEv := fEventLoop.waitForEvent();
            fEventLoop.notify(aEv);
        until fEventLoop.isTerminated();
    end;

    procedure TFanoApplication.initialize();
    begin
        fEventLoop.initialize();
    end;

    procedure TFanoApplication.shutdown();
    begin
        fEventLoop.shutdown();
    end;

    function TFanoApplication.run() : IRunnable;
    begin
        initialize();
        try
            result := runEventLoop();
        finally
            shutdown();
        end;
    end;
end.
