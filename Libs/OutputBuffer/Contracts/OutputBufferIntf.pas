{*!
 * Fano Web Framework (https://fano.juhara.id)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit OutputBufferIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to buffer
     * standard output to a storage
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *-------------------------------------------------*)
    IOutputBuffer = interface
        ['{F84DF7E8-A03E-4244-89F2-0A88C196F41B}']

        {------------------------------------------------
         begin output buffering
        -----------------------------------------------}
        function beginBuffering() : IOutputBuffer;

        {------------------------------------------------
         end output buffering
        -----------------------------------------------}
        function endBuffering() : IOutputBuffer;

        {------------------------------------------------
         read output buffer content
        -----------------------------------------------}
        function read() : string;

        {------------------------------------------------
         read output buffer content and empty the buffer
        -----------------------------------------------}
        function flush() : string;

        {------------------------------------------------
         read content length
        -----------------------------------------------}
        function size() : int64;
    end;

implementation
end.
