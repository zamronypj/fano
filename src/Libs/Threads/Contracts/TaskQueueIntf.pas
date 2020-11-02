{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}

unit TaskQueueIntf;

interface

{$MODE OBJFPC}

uses

    RunnableIntf;

type

    TTaskItem = record
        work : IRunnable;
    end;
    PTaskItem = ^TTaskItem;

    (*!------------------------------------------------
     * generic queue contract
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    ITaskQueue = interface
        ['{A50F95C0-AD03-4D75-8A5A-C74C7B4FC15C}']

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

end.
