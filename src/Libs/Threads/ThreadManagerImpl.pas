{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadManagerImpl;

interface

{$MODE OBJFPC}
{$H+}

uses

    Classes,
    SyncObjs,
    fgl,
    RunnableIntf;

type

    (*!------------------------------------------------
     * class that manage one or more worker thread
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    generic TThreadManager<T: TThread> = class(TInterfacedObject, IRunnable)
    private
        fList : TFPGObjectList<T>;

        procedure terminateThreads();
        procedure waitThreads();
        procedure cleanupThreads();
    public
        constructor create(const numThread : integer);
        destructor destroy(); override;
        function run() : IRunnable;
    end;

implementation

    constructor TThreadManager<T: TThread>.create(const numThread : integer);
    var threadIdx : integer;
    begin
        fList := TFPGObjectList<T>.create(numThread);
        for threadIdx := 0 to numThread-1 do
        begin
            fList.add(T.create());
        end;
    end;

    destructor TThreadManager<T: TThread>.destroy();
    begin
        stopThreads();
        waitForThreads();
        cleanupThreads();
        inherited destroy();
    end;

    procedure TThreadManager<T: TThread>.waitThreads();
    var threadIdx : integer;
    begin
        for threadIdx :=0 to fList.count-1 do
        begin
            fList[threadIdx].waitFor();
        end;
    end;

    procedure TThreadManager<T: TThread>.cleanupThreads();
    var threadIdx : integer;
    begin
        for threadIdx := fList.count-1 downto 0 do
        begin
            fList[threadIdx].free();
            fList.delete(threadIdx);
        end;
    end;

    procedure TThreadManager<T: TThread>.terminateThreads();
    var threadIdx : integer;
    begin
        for threadIdx :=0 to fList.count-1 do
        begin
            fList[threadIdx].terminate();
        end;
    end;

    function TThreadManager<T: TThread>.run() : IRunnable;
    var threadIdx : integer;
    begin
        for threadIdx :=0 to fList.count-1 do
        begin
            fList[threadIdx].start();
        end;
    end;
end.
