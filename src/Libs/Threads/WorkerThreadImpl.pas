{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit WorkerThreadImpl;

interface

{$MODE OBJFPC}
{$H+}

uses
    {$IFDEF UNIX}
    cthreads,
    cmem,
    {$ENDIF}
    Classes,
    SyncObjs,
    RunnableIntf,
    TaskQueueIntf;

type


    (*!------------------------------------------------
     * generic worker thread that execute runnable object
     * in queue until it is terminated.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TWorkerThread = class(TThread)
    private
        fQueue : ITaskQueue;
    public
        constructor create(const aQueue : ITaskQueue);
        destructor destroy(); override;
        procedure execute(); override;
    end;

implementation

    constructor TWorkerThread.create(const aQueue : ITaskQueue);
    begin
        //create thread with default stack frame size
        inherited create(false);
        fQueue := aQueue;
    end;

    destructor TWorkerThread.destroy();
    begin
        fQueue := nil;
        inherited destroy();
    end;

    procedure TWorkerThread.execute();
    var task : PTaskItem;
    begin
        while not terminated do
        begin
            //get task to run from thread-safe queue
            task := fQueue.dequeue();
            try
                //TODO: add timeout so that long-running task does not starve thread
                //instead yield execution so current thread can process other task
                task^.work.run();
            finally
                task^.work := nil;
                dispose(task);
            end;
        end;
    end;
end.
