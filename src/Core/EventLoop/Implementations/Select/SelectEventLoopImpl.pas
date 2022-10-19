{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/fanoframework/fano
 * @copyright Copyright (c) 2018 - 2022 Zamrony P. Juhara
 * @license   https://github.com/fanoframework/fano/blob/master/LICENSE (MIT)
 *}
unit SelectEventLoopImpl;

interface

{$MODE OBJFPC}

uses

    EventCollectionIntf;

type

    (*!-----------------------------------------------
     * IEventLoop implementation using select()
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    TSelectEventLoop = class(TInterfacedObject, IEventLoop)
    private
    public
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

    (*!-----------------------------------------------
     * initialize event loop
     *------------------------------------------------
     * e.g., allocate array for file descriptors, timeout etc
     *-----------------------------------------------*)
    procedure TSelectEventLoop.initialize();
    begin
    end;

    (*!-----------------------------------------------
     * shutdown
     *------------------------------------------------
     * e.g., close open file descriptors, deallocate array
     * for file descriptors, timeout, etc
     *-----------------------------------------------*)
    procedure TSelectEventLoop.shutdown();
    begin
    end;

    (*!-----------------------------------------------
     * wait for event
     *------------------------------------------------
     * e.g., prepare timeout, select(), epoll etc
     * @return collection of one or more events
     *-----------------------------------------------*)
    function TSelectEventLoop.waitForEvent() : IEventCollection;
    begin
    end;

    (*!-----------------------------------------------
     * notify all registered callback about events
     *------------------------------------------------
     * @param ev collection of one or more events
     *-----------------------------------------------*)
    procedure TSelectEventLoop.notify(const ev : IEventCollection);
    begin
    end;

    (*!-----------------------------------------------
     * check if event loop should terminate
     *------------------------------------------------
     * @return boolean true if terminated
     *-----------------------------------------------*)
    function TSelectEventLoop.isTerminated() : boolean;
    begin
    end;

end.
