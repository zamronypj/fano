{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit ThreadSafeQueueImpl;

interface

{$MODE OBJFPC}

uses

    SyncObjs,
    QueueIntf;

type

    (*!------------------------------------------------
     * thread-safe blocking queue which implements
     * IQueue<T> interface. This implementation wraps
     * non thread-safe IQueue<T> implementation into thread-safe
     * implementation.
     *
     * The idea is borrowed from TBlockingQueue by David Heffernan
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     * @link https://stackoverflow.com/questions/15027726/how-to-make-a-thread-finish-its-work-before-being-freed/15033839#15033839
     *-----------------------------------------------*)
    generic TThreadSafeQueue<T> = class(TInterfacedObject, specialize IQueue<T>)
    private
        //non thread-safe queue
        fQueue : IQueue<T>;

        //critical section to protect access to actual queue
        fLock: TCriticalSection;

        //event for signaling queue empty status
        fNotEmpty: TEvent;
    public
        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------
         * @param actualQueue actual queue to be wrapped
         *-----------------------------------------------*)
        constructor create(const actualQueue : IQueue<T>);

        (*!------------------------------------------------
         * destructor
         *-----------------------------------------------*)
        destructor destroy(); override;

        (*!------------------------------------------------
         * add value to queue
         *-----------------------------------------------
         * @param value object/data to add
         * @return true if value can be added to queue
         *-----------------------------------------------*)
        function enqueue(const value: T): boolean;

        (*!------------------------------------------------
         * retrieve value and remove it from queue
         *-----------------------------------------------
         * @return value object/data
         *-----------------------------------------------*)
        function dequeue() : T;

        (*!------------------------------------------------
         * retrieve current queue size
         *-----------------------------------------------
         * @return total number of item in queue
         *-----------------------------------------------*)
        function getSize() : integer;

        property size : integer read getSize;
    end;

implementation

    (*!------------------------------------------------
     * constructor
     *-----------------------------------------------
     * @param actualQueue actual queue to be wrapped
     *-----------------------------------------------*)
    constructor TThreadSafeQueue<T>.create(const actualQueue : IQueue<T>);
    begin
        fQueue := actualQueue;
        fLock := TCriticalSection.create;
        fNotEmpty := TEvent.create(nil, true, false, '');
    end;

    (*!------------------------------------------------
     * destructor
     *-----------------------------------------------*)
    destructor TThreadSafeQueue<T>.destroy();
    begin
        fQueue := nil;
        fLock.free();
        fNotEmpty.free();
        inherited destroy();
    end;

    (*!------------------------------------------------
     * add value to queue
     *-----------------------------------------------
     * @param value object/data to add
     * @return true if value can be added to queue
     *-----------------------------------------------*)
    function TThreadSafeQueue<T>.enqueue(const value: T): boolean;
    var wasEmpty: boolean;
    begin
        fLock.acquire();
        try
            wasEmpty := fQueue.size = 0;
            result := fQueue.enqueue(value);
            if wasEmpty then
            begin
                //signal that queue is not empty anymore
                fNotEmpty.setEvent();
            end;
        finally
            fLock.release();
        end;
    end;

    (*!------------------------------------------------
     * retrieve value and remove it from queue
     *-----------------------------------------------
     * @return value object/data
     *-----------------------------------------------*)
    function TThreadSafeQueue<T>.dequeue() : T;
    begin
        fLock.acquire();
        try

            //need to do wait in loop because there is chance that
            //by the time fNotEmpty is signaled, other thread may dequeue it
            //causing queue to be empty again before we can reacquire the lock
            while fQueue.size = 0 do
            begin
                //release lock, so other thread can access fQueue
                fLock.release();
                try
                    //wait until queue not empty
                    fNotEmpty.waitFor();
                finally
                    //reacquire lock, so other thread cannot access fQueue
                    fLock.acquire();
                end;
            end;

            result := fQueue.dequeue();

            if fQueue.size = 0 then
            begin
                //signal that queue is empty
                fNotEmpty.resetEvent();
            end;
        Finally
            fLock.release();
        End;
    end;

    (*!------------------------------------------------
     * retrieve current queue size
     *-----------------------------------------------
     * @return total number of item in queue
     *-----------------------------------------------*)
    function TThreadSafeQueue<T>.getSize() : integer;
    begin
        fLock.acquire();
        try
            result := fQueue.size;
        finally
            fLock.release();
        end;
    end;

end.
