{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit QueueAdapterImpl;

interface

{$MODE OBJFPC}

uses

    gqueue,
    QueueIntf;

type

    (*!------------------------------------------------
     * non thread-safe adapter class for fcl-stl TQueue
     * which implements IQueue<T> interface.
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    generic TQueueAdapter<T> = class(TInterfacedObject, specialize IQueue<T>)
    private
        fQueue : TQueue<T>;
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

    constructor TQueueAdapter<T>.create();
    begin
        fQueue := TQueue<T>.create();
    end;

    destructor TQueueAdapter<T>.destroy();
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
    function TQueueAdapter<T>.enqueue(const value: T): boolean;
    begin
        fQueue.push(value);
        result := true;
    end;

    (*!------------------------------------------------
     * retrieve value and remove it from queue
     *-----------------------------------------------
     * @return value object/data
     *-----------------------------------------------*)
    function TQueueAdapter<T>.dequeue() : T;
    begin
        result := fQueue.front;
        fQueue.pop();
    end;

    (*!------------------------------------------------
     * retrieve current queue size
     *-----------------------------------------------
     * @return total number of item in queue
     *-----------------------------------------------*)
    function TQueueAdapter<T>.getSize() : integer;
    begin
        result := fQueue.size;
    end;

end.
