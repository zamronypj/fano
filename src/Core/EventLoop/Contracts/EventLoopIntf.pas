{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit EventLoopIntf;

interface

{$MODE OBJFPC}

uses

    EventCollectionIntf;

type

    (*!-----------------------------------------------
     * interface for any class that for event loop
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IEventLoop = interface
        ['{FF9DAA03-0500-437C-8D4D-E8B4D9D3763F}']

        (*!-----------------------------------------------
         * initialize event loop
         *------------------------------------------------
         * e.g., allocate array for file descriptors, timeout etc
         *-----------------------------------------------*)
        procedure initialize();

        (*!-----------------------------------------------
         * shutdown
         *------------------------------------------------
         * e.g., close open file descriptors, deallocate array
         * for file descriptors, timeout, etc
         *-----------------------------------------------*)
        procedure shutdown();

        (*!-----------------------------------------------
         * wait for event
         *------------------------------------------------
         * e.g., prepare timeout, select(), epoll etc
         * @return collection of one or more events
         *-----------------------------------------------*)
        function waitForEvent() : IEventCollection;

        (*!-----------------------------------------------
         * notify all registered callback about events
         *------------------------------------------------
         * @param ev collection of one or more events
         *-----------------------------------------------*)
        procedure notify(const ev : IEventCollection);

        (*!-----------------------------------------------
         * check if event loop should terminate
         *------------------------------------------------
         * @return boolean true if terminated
         *-----------------------------------------------*)
        function isTerminated() : boolean;
    end;

implementation

end.
