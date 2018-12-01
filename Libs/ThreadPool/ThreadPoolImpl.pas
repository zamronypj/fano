{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit ThreadPoolImpl;

interface

{$MODE OBJFPC}

uses

    ThreadIntf,
    ThreadPoolIntf;

type

    (*!------------------------------------------------
     * basic class thet having capability to manage
     * one or more worker threads and distribute the work
     * between worker threads
     *
     * The main goal of this interface is to allow several
     * threads to be managed by thread pool. By allowing
     * application to reuse thread instead of create new thread
     * every time a work need to be done, we hope to increase
     * performance
     *
     * When application needs a thread instance to handle a work,
     * instead of creating a thread on their own, application
     * asks from the thread pool.
     * The thread pool returns worker thread that is idle
     * from its pool of thread. If it can't find idle worker
     * thread, it tries to spawn new thread and add it to its pool
     * and hands it to application.
     * If somehow thread pool is not allowed to spawn new thread
     * (for example number of max thread has been reach), thread pool
     * waits until an idle thread is available. If waiting time
     * exceeds timeout value then thread pool raise exception
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TThreadPool = class(TInterfacedObject, IThreadPool)
    private
    public

        (*!------------------------------------------------
         * get idle thread from pool
         *-----------------------------------------------
         * @return idle thread
         * @throws EThreadPoolTimeout if thread pool cannot spawn
         * idle thread in given time interval
         *-----------------------------------------------*)
        function requestIdleThread() : IThread;
    end;

implementation

    (*!------------------------------------------------
     * get idle thread from pool
     *-----------------------------------------------
     * @return idle thread
     * @throws EThreadPoolTimeout if thread pool cannot spawn
     * idle thread in given time interval
     *-----------------------------------------------*)
    function TThreadPool.requestIdleThread() : IThread;
    begin

    end;

end.
