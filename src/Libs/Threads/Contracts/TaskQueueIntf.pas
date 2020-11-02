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

    RunnableIntf,
    QueueIntf;

type

    TTaskItem = record
        work : IRunnable;
    end;
    PTaskItem = ^TTaskItem;

    ITaskQueue = specialize IQueue<PTaskItem>;

implementation

end.
