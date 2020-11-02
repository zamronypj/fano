{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit TaskQueueImpl;

interface

{$MODE OBJFPC}

uses

    gqueue,
    TaskQueueIntf;

type

    TTaskQueueInst = specialize TQueue<PTaskItem>;

    (*!------------------------------------------------
     * non thread-safe adapter class for fcl-stl TQueue
     * which implements IQueue<T> interface.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TTaskQueue = class(TInterfacedObject, ITaskQueue)
    private
        fQueue : TTaskQueueInst;
    public
        (*!------------------------------------------------
         * constructor
         *-----------------------------------------------*)
        constructor create();

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
        function enqueue(const value: PTaskItem): boolean;

        (*!------------------------------------------------
         * retrieve value and remove it from queue
         *-----------------------------------------------
         * @return value object/data
         *-----------------------------------------------*)
        function dequeue() : PTaskItem;

        (*!------------------------------------------------
         * retrieve current queue size
         *-----------------------------------------------
         * @return total number of item in queue
         *-----------------------------------------------*)
        function getSize() : integer;

        property size : integer read getSize;
    end;

implementation

    constructor TTaskQueue.create();
    begin
        fQueue := TTaskQueueInst.create();
    end;

    destructor TTaskQueue.destroy();
    begin
        fQueue.free();
        inherited destroy();
    end;

    (*!------------------------------------------------
     * add value to queue
     *-----------------------------------------------
     * @param value object/data to add
     * @return true if value can be added to queue
     *-----------------------------------------------*)
    function TTaskQueue.enqueue(const value: PTaskItem): boolean;
    begin
        fQueue.push(value);
        result := true;
    end;

    (*!------------------------------------------------
     * retrieve value and remove it from queue
     *-----------------------------------------------
     * @return value object/data
     *-----------------------------------------------*)
    function TTaskQueue.dequeue() : PTaskItem;
    begin
        result := fQueue.front;
        fQueue.pop();
    end;

    (*!------------------------------------------------
     * retrieve current queue size
     *-----------------------------------------------
     * @return total number of item in queue
     *-----------------------------------------------*)
    function TTaskQueue.getSize() : integer;
    begin
        result := fQueue.size;
    end;

end.
