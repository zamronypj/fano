{*!
 * Fano Web Framework (https://fanoframework.github.io)
 *
 * @link      https://github.com/zamronypj/fano
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/zamronypj/fano/blob/master/LICENSE (GPL 3.0)
 *}

unit OutputBufferStreamIntf;

interface

{$MODE OBJFPC}
{$H+}

type

    (*!------------------------------------------------
     * interface for any class having capability to store
     * of output buffering content
     *
     * @author Zamrony P. Juhara <zamronypj@yahoo.com>
     *--------------------------------------------------*)
    IOutputBufferStream = interface
        ['{F15C85F6-B420-4CFD-8E7D-496F59C3C58E}']
        function assignToFile(var f : TextFile) : IOutputBufferStream;
        function clear() : IOutputBufferStream;
        function seek(const streamPos : integer) : IOutputBufferStream;
        function getContent() : string;
        function size() : int64;
    end;

implementation



end.
