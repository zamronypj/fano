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
    fgl,
    RunnableIntf,
    QueueIntf;

type

    IRunnableQueue = specialize IQueue<IRunnable>;

    (*!------------------------------------------------
     * generic worker thread that execute runnable object
     * in queue until it is terminated.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TWorkerThread = class(TThread)
    private
        fQueue : IRunnableQueue;
    public
        constructor create(const queue : IRunnableQueue);
        destructor destroy(); override;
        procedure execute();
    end;

implementation

    constructor TWorkerThread.create(const queue : IRunnableQueue);
    begin
        fQueue := queue;
    end;

    destructor TWorkerThread.destroy();
    begin
        fQueue := nil;
        inherited destroy();
    end;

    procedure TWorkerThread.execute();
    var runnableObj : IRunnable;
    begin
        while not terminated do
        begin
            runnableObj := fQueue.dequeue();
            runnableObj.run();
        end;
    end;
end.
