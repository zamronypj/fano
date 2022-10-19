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

type

    (*!-----------------------------------------------
     * interface for any class that for event
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-----------------------------------------------*)
    IEvent = interface
        ['{CD982E65-5F6E-42FC-A0F3-797FE018C03B}']

        (*!-----------------------------------------------
         * check if event file descriptor is ready for read
         *------------------------------------------------
         * when true then we can read from file descriptor
         * without blocking
         *------------------------------------------------
         * @return boolean true if ready for read
         *-----------------------------------------------*)
        function isRead() : boolean;

        (*!-----------------------------------------------
         * check if event file descriptor is ready for write
         *------------------------------------------------
         * when true then we can write to file descriptor
         * without blocking
         *------------------------------------------------
         * @return boolean true if ready for write
         *-----------------------------------------------*)
        function isWrite() : boolean;

        (*!-----------------------------------------------
         * event file descriptor that is ready/write
         *------------------------------------------------
         * @return boolean true if terminated
         *-----------------------------------------------*)
        function isTerminated() : boolean;
    end;

implementation

end.
